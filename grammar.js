const goGrammar = require('tree-sitter-go/grammar.js');

module.exports = grammar(goGrammar, {
  name: 'gsx',

  externals: $ => [$.embedded_text, $.embedded_text_dq, $.raw_text],

  conflicts: $ => [
    // tree-sitter-go's own 8 internal conflicts — MUST be re-included:
    // a `conflicts` array in the overrides REPLACES the base grammar's
    // conflicts (it does not merge), so omitting these resurfaces Go's own
    // ambiguities (e.g. identifier '.' → selector_expression vs
    // qualified_type). Copied verbatim from tree-sitter-go's grammar.js;
    // re-verify on every upstream version bump.
    [$._simple_type, $._expression],
    [$._simple_type, $.generic_type, $._expression],
    [$.qualified_type, $._expression],
    [$.generic_type, $._simple_type],
    [$.parameter_declaration, $._simple_type],
    [$.type_parameter_declaration, $._simple_type, $._expression],
    [$.type_parameter_declaration, $._expression],
    [$.type_parameter_declaration, $._simple_type, $.generic_type, $._expression],
    // gsx-added: a composable value's first part reduces to class_part
    // (multi-part path) or composable_first_part (single-part path); the
    // next token (',' vs '}') resolves it.
    [$.class_part, $.composable_first_part],
    // A `{ x |> f … }` value is a piped `hole` (expr_attribute) or the first
    // `class_part` of a composable multi-list; the next token (',' vs '}')
    // resolves it.
    [$.class_part, $.hole],
  ],

  rules: {
    // Redeclares Go's own top-level-declaration choice list (rule NAMES
    // only) plus component_declaration — same redeclaration pattern as
    // _expression in Phase 1.
    _top_level_declaration: $ => choice(
      $.package_clause,
      $.function_declaration,
      $.method_declaration,
      $.import_declaration,
      $.component_declaration,
    ),

    // Reuses Go's own parameter_list (receiver + parameters) and
    // type_parameter_list (generics) verbatim — no custom regex-blob
    // capture needed now that Go is native.
    component_declaration: $ => seq(
      'component',
      optional(field('receiver', $.parameter_list)),
      field('name', $.identifier),
      optional(field('type_parameters', $.type_parameter_list)),
      field('parameters', $.parameter_list),
      field('body', $.component_body),
    ),

    component_body: $ => seq('{', repeat($._child), '}'),

    _expression: $ => choice(
      $.unary_expression,
      $.binary_expression,
      $.selector_expression,
      $.index_expression,
      $.slice_expression,
      $.call_expression,
      $.type_assertion_expression,
      $.type_conversion_expression,
      $.type_instantiation_expression,
      $.identifier,
      alias(choice('new', 'make'), $.identifier),
      $.composite_literal,
      $.func_literal,
      $._string_literal,
      $.int_literal,
      $.float_literal,
      $.imaginary_literal,
      $.rune_literal,
      $.nil,
      $.true,
      $.false,
      $.iota,
      $.parenthesized_expression,
      $.element,
      $.fragment,
      // f/js/css literals are all valid as bare Go values (var initializers,
      // call arguments, go_block statements, …), not just attribute values —
      // the sublanguage tag only changes how the literal's text is escaped
      // at codegen time, not where it's syntactically permitted.
      $.embedded_f_literal,
      $.embedded_js_literal,
      $.embedded_css_literal,
    ),

    // f`…`/f"…": generic interpolating literal. js/css embed their
    // sublanguage; f does not — all three take @{ } holes and support both
    // delimiters (embedded_text stops at a backtick; embedded_text_dq stops
    // at a double-quote — external scanner, lifted from the pre-existing
    // shipped grammar's scan_embedded_text/scan_embedded_text_dq).
    // The prefix+delimiter is ONE combined token (`` f` ``, `f"`, etc.), not a
    // bare `'f'`/`'js'`/`'css'` string token — otherwise those literals shadow
    // Go identifiers named exactly `f`/`js`/`css` (a `'f'` token wins over the
    // `identifier` regex for the string "f", breaking e.g. a receiver named
    // `f`). Combining prefix+delimiter means `f` alone is never a special
    // token. The opener is aliased to `embedded_open` (highlighting colors the
    // prefix+delimiter as the literal marker); the matching closing delimiter
    // follows. `token(prec(1, …))` keeps `` f` `` winning over `<` etc.
    embedded_f_literal: $ => choice(
      seq(alias($._f_bt_open, $.embedded_open), repeat(choice($.embedded_text, $.at_hole)), '`'),
      seq(alias($._f_dq_open, $.embedded_open), repeat(choice($.embedded_text_dq, $.at_hole)), '"'),
    ),
    embedded_js_literal: $ => choice(
      seq(alias($._js_bt_open, $.embedded_open), repeat(choice($.embedded_text, $.at_hole)), '`'),
      seq(alias($._js_dq_open, $.embedded_open), repeat(choice($.embedded_text_dq, $.at_hole)), '"'),
    ),
    embedded_css_literal: $ => choice(
      seq(alias($._css_bt_open, $.embedded_open), repeat(choice($.embedded_text, $.at_hole)), '`'),
      seq(alias($._css_dq_open, $.embedded_open), repeat(choice($.embedded_text_dq, $.at_hole)), '"'),
    ),
    _f_bt_open: $ => token(prec(1, seq('f', '`'))),
    _f_dq_open: $ => token(prec(1, seq('f', '"'))),
    _js_bt_open: $ => token(prec(1, seq('js', '`'))),
    _js_dq_open: $ => token(prec(1, seq('js', '"'))),
    _css_bt_open: $ => token(prec(1, seq('css', '`'))),
    _css_dq_open: $ => token(prec(1, seq('css', '"'))),

    // @{ expr } / @{ expr |> stage |> stage } hole inside f/js/css literal
    // text. A pipe stage is syntactically just a real Go expression
    // (typically identifier or call_expression) — codegen handles seed-first
    // forward-application, the grammar only needs the shape.
    at_hole: $ => seq('@{', $._expression, repeat(seq('|>', $._expression)), '}'),

    embedded_attribute: $ => prec(1, seq(
      field('name', $.attribute_name),
      '=',
      choice(
        field('value', $.embedded_f_literal),
        field('value', $.embedded_js_literal),
        field('value', $.embedded_css_literal),
      ),
    )),

    element: $ => choice(
      seq('<', field('name', $.tag_name), optional(field('type_arguments', $.type_arguments)), repeat($.attribute), '/>'),
      seq(
        '<', field('open_name', $.tag_name), optional(field('type_arguments', $.type_arguments)), repeat($.attribute), '>',
        repeat($._child),
        '</', field('close_name', $.tag_name), '>',
      ),
    ),

    // Tag name: one token covering plain (<div>), dotted/qualified
    // (<ui.Button>, <p.Content>), and hyphenated custom-element/web-component
    // (<el-dialog>, <turbo-frame>) names. A dedicated token (letters, then
    // letters/digits/./-) rather than composing identifiers, because a
    // hyphen can't be a token boundary (it's the minus operator). It does
    // NOT shadow Go's `identifier`: tree-sitter's lexer is context-sensitive,
    // so tag_name is only a candidate in element-name position (right after a
    // markup `<`), never where a Go identifier is expected — verified.
    tag_name: $ => token(/[A-Za-z][A-Za-z0-9.\-]*/),

    attribute: $ => choice(
      $.embedded_attribute,
      $.ordered_attrs_attribute,
      $.composable_attribute,
      $.static_attribute,
      $.expr_attribute,
      $.bool_attribute,
      $.spread_attribute,
      $.conditional_attribute,
      $.content_comment,
    ),

    attribute_name: $ => /[A-Za-z_@:][A-Za-z0-9_@:.\-]*/,

    // Ordered-attrs literal value: name={{ "k": v, "b", ... }} — a `{{ }}`
    // comma-list of key(:value)? pairs (an ast.Attrs literal). `key` is a Go
    // expression (usually a string), value a Go expression; a bare key is a
    // boolean attr. Distinct from go_block `{{ }}` (statements) by position
    // (attribute value) and content (pairs, not statements).
    ordered_attrs_attribute: $ => seq(
      field('name', $.attribute_name), '=',
      '{{', optional($._attr_pair_list), '}}',
    ),
    _attr_pair_list: $ => seq($.attr_pair, repeat(seq(',', $.attr_pair)), optional(',')),
    attr_pair: $ => seq(
      field('key', $._expression),
      optional(seq(':', field('value', $._expression))),
    ),

    // A composable value (class/style in real gsx) — distinguished from a
    // single-expression expr_attribute by VALUE SHAPE, not by the attribute
    // name: it requires either 2+ comma-separated parts, or a single part
    // that is itself composable-only (has a `: cond` guard, `|>` stages, or
    // is a value-form if/switch). A bare `{ single_expr }` stays
    // expr_attribute. Restricting composable to the class/style NAMES is
    // deferred to the compiler (tree-sitter is a highlighter and doesn't run
    // that semantic check) — special-casing the names at the token level
    // shadows attribute_name and needs GLR conflicts; value-shape avoids it.
    composable_attribute: $ => seq(
      field('name', $.attribute_name),
      '=', '{',
      $._composable_value,
      '}',
    ),

    _composable_value: $ => choice(
      // 2+ parts — the unambiguously-composable comma list.
      seq($.class_part, repeat1(seq(',', $.class_part)), optional(',')),
      // single composable-only part (cond/stages/value-form) + optional
      // trailing comma. A plain single expr is NOT here — that's expr_attribute.
      seq($.composable_first_part, optional(',')),
    ),

    class_part: $ => choice(
      $.class_value_form,
      seq(
        field('expr', $._expression),
        repeat(seq('|>', field('stage', $._expression))),
        optional(seq(':', field('cond', $._expression))),
      ),
    ),

    // A single part that can't be confused with a bare Go expression OR a
    // single piped hole (so a one-part composable value is unambiguous vs
    // expr_attribute's `hole`, which now also carries `|>` stages). Only a
    // `: cond` guard or a value-form qualifies here; a single piped part
    // (`{ x |> f }`) routes to the hole instead — semantically identical for a
    // class value, and it removes the hole-vs-composable-single-pipe conflict.
    // Visible (no leading _) so it can appear in `conflicts`.
    composable_first_part: $ => choice(
      $.class_value_form,
      seq(
        field('expr', $._expression),
        seq(':', field('cond', $._expression)),
      ),
    ),

    // A value-form arm inside class/style: if/switch whose block bodies are
    // themselves class-part lists (class strings), not markup children.
    // Condition is a plain Go expression — class value-forms don't loop
    // (no for/range), so no for_clause/range_clause here. The block body is
    // `_class_body` (a plain 1+ comma-list, single bare expr OK) — NOT
    // `_composable_value`: inside a block there's no expr_attribute to
    // disambiguate from, so a lone `{ "extra" }` string is valid.
    class_value_form: $ => choice($.class_if_form, $.class_switch_form),

    class_if_form: $ => seq(
      alias('if', $.keyword),
      field('condition', $._cf_condition),
      '{', optional($._class_body), '}',
      repeat($.class_else_clause),
    ),

    class_else_clause: $ => seq(
      alias('else', $.keyword),
      optional(seq(alias('if', $.keyword), field('condition', $._cf_condition))),
      '{', optional($._class_body), '}',
    ),

    // switch value-form: `switch EXPR { case L,L: body  default: body }`.
    // Each case body runs to the next case/default/} (unbraced).
    class_switch_form: $ => seq(
      alias('switch', $.keyword),
      // condition: a plain expr, or a type-switch guard `x.(type)`.
      optional(field('condition', choice($._expression, $._type_switch_guard))),
      '{', repeat($.class_switch_case), '}',
    ),

    // `v.(type)` — a type-switch guard. Not a normal expression (`.(type)`
    // uses the `type` keyword), so it needs its own shape.
    _type_switch_guard: $ => seq($._expression, '.', '(', 'type', ')'),

    class_switch_case: $ => seq(
      choice(
        // case values are Go expressions — a type name in a type-switch
        // (`case string:`) parses fine as an identifier; the type-vs-value
        // distinction is semantic, not syntactic.
        seq(alias('case', $.keyword), $._expression, repeat(seq(',', $._expression))),
        alias('default', $.keyword),
      ),
      ':',
      // case body: an unbraced class-part list, or a `{ … }`-braced value.
      optional(choice($._class_body, seq('{', optional($._class_body), '}'))),
    ),

    // A plain comma-list of class parts (single bare expr allowed) — used
    // only inside value-form blocks, where no expr_attribute competes.
    _class_body: $ => seq(
      $.class_part,
      repeat(seq(',', $.class_part)),
      optional(','),
    ),

    static_attribute: $ => seq(field('name', $.attribute_name), '=', field('value', $._string_literal)),

    // Reuses 2a's `hole` rule directly for the value — name={ expr }.
    expr_attribute: $ => prec(-1, seq(field('name', $.attribute_name), '=', field('value', $.hole))),

    bool_attribute: $ => prec(-1, field('name', $.attribute_name)),

    spread_attribute: $ => seq('{', field('value', $._expression), '...', '}'),

    conditional_attribute: $ => seq(
      '{',
      alias(choice('if', 'for'), $.keyword),
      field('condition', choice($._expression, $.for_clause, $.range_clause)),
      '{', repeat($.attribute), '}',
      repeat($.attribute_else_clause),
      '}',
    ),

    attribute_else_clause: $ => seq(
      alias('else', $.keyword),
      optional(seq(alias('if', $.keyword), field('condition', $._expression))),
      '{', repeat($.attribute), '}',
    ),

    fragment: $ => seq(
      token(seq('<', '>')),
      repeat($._child),
      token(seq('<', '/', '>')),
    ),

    _child: $ => choice(
      $.raw_element,
      $.element,
      $.fragment,
      $.doctype,
      $.html_comment,
      $.content_comment,
      $.hole,
      $.go_block,
      $.control_flow,
      $.text,
    ),

    // <script>/<style> raw-text elements: bodies are NOT markup (braces are
    // literal). Interpolation is @{ expr } (at_hole), same as f/js/css
    // literals — raw_text (external scanner) stops before @{ or the matching
    // </script>/</style>. The close tag name is a plain identifier
    // (case-insensitive match handled by the scanner's stop, node is generic).
    raw_element: $ => seq(
      '<', field('open_name', alias($._raw_tag_token, $.tag_name)),
      repeat($.attribute), '>',
      repeat(choice($.raw_text, $.at_hole)),
      '</', field('close_name', alias(/[A-Za-z]+/, $.tag_name)), '>',
    ),
    // script/style tag-name token with precedence over `identifier` so a
    // raw-text element wins over a regular element at `<script`/`<style`.
    _raw_tag_token: $ => token(prec(1, /[Ss][Cc][Rr][Ii][Pp][Tt]|[Ss][Tt][Yy][Ll][Ee]/)),

    // {{ Go statements }} — the escape hatch for pure statements between
    // markup siblings. Body is Go statements (native), reusing Go's own
    // statement_list.
    go_block: $ => seq('{{', optional($.statement_list), '}}'),

    // <!DOCTYPE html>
    doctype: $ => seq('<!', /[Dd][Oo][Cc][Tt][Yy][Pp][Ee]/, /[^>]*/, '>'),

    // <!-- comment -->
    html_comment: $ => seq('<!--', /([^-]|-[^-]|--[^>])*/, '-->'),

    // Comment-only brace: block {/* … */} or line {// … \n}. Valid in both
    // child and attribute position.
    content_comment: $ => choice(
      seq('{/*', /([^*]|\*[^/])*/, '*/}'),
      seq(token(seq('{//', /[^\n]*/)), '}'),
    ),

    // Prototype-only: hole body is just a real Go expression (element/fragment
    // already included via _expression). Testing whether this is sufficient
    // vs. needing a separate markup-sequence alternative.
    // { expr } or { expr |> stage |> stage } — a hole may carry a pipe chain
    // (same shape as at_hole). A pipe stage is syntactically a Go expression;
    // codegen does seed-first forward-application.
    // A hole value is any Go expression — f/js/css literals are all valid
    // bare _expression alternatives, so no separate listing is needed here.
    // Inlined (not a shared hidden rule) so the composable-vs-hole ambiguity
    // resolves to `hole`, which `conflicts` can name.
    hole: $ => seq('{', $._expression, repeat(seq('|>', $._expression)), '}'),

    // Prototype-only: condition reuses Go's own for_statement condition shape
    // (plain expr, or a real for_clause/range_clause for `for`) — no
    // go_cond_text scanner needed; the block body is markup children, not Go
    // statements (can't reuse Go's native if_statement — its block holds
    // _statement).
    control_flow: $ => seq(
      '{',
      alias(choice('if', 'for', 'switch'), $.keyword),
      field('condition', $._cf_condition),
      '{', repeat($._child), '}',
      repeat($.else_clause),
      '}',
    ),

    // if/switch condition may carry an initializer (`if x := f(); x != ""`);
    // for uses a for_clause/range_clause. Mirrors Go's own
    // if_statement/expression_switch_statement initializer shape.
    _cf_condition: $ => choice(
      seq(optional(seq(field('initializer', $._simple_statement), ';')), $._expression),
      $.for_clause,
      $.range_clause,
    ),

    else_clause: $ => seq(
      alias('else', $.keyword),
      optional(seq(alias('if', $.keyword), field('condition', $._cf_condition))),
      '{', repeat($._child), '}',
    ),

    text: $ => token(prec(-1, /[^<{}]+/)),
  },
});
