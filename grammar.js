module.exports = grammar({
  name: 'gsx',
  // External tokens (order matches enum in scanner.c):
  //   go_text        — general Go text (top-level, go_block, expr_attribute)
  //   raw_text       — raw HTML text (Task 8)
  //   pipe           — pipe operator (Task 9)
  //   go_cond_text   — Go text for control-flow condition (stops at depth-0 '{')
  //   go_interp_text — Go text inside interpolation { } (refuses if/for/switch)
  //   go_spread_text — Go text for spread/splat expr (refuses if/for/switch; stops at depth-0 '...')
  //   style_go_text  — Go-ish text after a top-level css`...` in a style attr value
  externals: $ => [$.go_text, $.raw_text, $.pipe, $.go_cond_text, $.go_interp_text, $.go_spread_text, $.style_go_text],
  extras: $ => [/\s/, $.line_comment, $.block_comment],
  rules: {
    source_file: $ => repeat($._top_level),
    _top_level: $ => choice($.component_declaration, $.go_chunk),
    go_chunk: $ => $.go_text,

    component_declaration: $ => seq(
      'component',
      optional(field('receiver', $.receiver)),
      field('name', $.identifier),
      field('parameters', $.parameter_list),
      field('body', $.body),
    ),
    receiver: $ => seq('(', optional($._paren_go), ')'),
    parameter_list: $ => seq('(', optional($._paren_go), ')'),
    // Matches parameter/receiver content with one level of nested parens
    // (covers func types like `href func(int) string`, pointer receivers, etc.)
    _paren_go: $ => token(prec(-1, /([^()]*\([^()]*\))*[^()]*/)),

    body: $ => seq('{', repeat($._node), '}'),
    _node: $ => choice(
      $.raw_element,
      $.element,
      $.fragment,
      $.doctype,
      $.html_comment,
      $.content_comment,
      $.interpolation,
      $.go_block,
      $.control_flow,
      $.text,
    ),

    fragment: $ => seq('<>', repeat($._node), '</>'),
    raw_element: $ => seq(
      seq('<', field('name', alias(/[Ss][Cc][Rr][Ii][Pp][Tt]|[Ss][Tt][Yy][Ll][Ee]/, $.tag_name)), repeat($.attribute), '>'),
      repeat(choice($.raw_text, $.at_hole)),
      seq('</', alias(/[A-Za-z]+/, $.tag_name), '>'),
    ),
    at_hole: $ => seq('@{', $.go_expr, '}'),
    doctype: $ => seq('<!', /[Dd][Oo][Cc][Tt][Yy][Pp][Ee]/, /[^>]*/, '>'),
    html_comment: $ => seq('<!--', /([^-]|-[^-]|--[^>])*/, '-->'),
    content_comment: $ => seq('{/*', /([^*]|\*[^/])*/, '*/}'),

    element: $ => choice(
      $.self_closing_element,
      seq($.start_tag, repeat($._node), $.end_tag),
    ),
    start_tag: $ => seq('<', field('name', $.tag_name), repeat($.attribute), '>'),
    end_tag: $ => seq('</', $.tag_name, '>'),
    self_closing_element: $ => seq('<', field('name', $.tag_name), repeat($.attribute), '/>'),
    tag_name: $ => /[A-Za-z][A-Za-z0-9.\-]*/,

    // Interpolation: { expr } or { expr? } or { markup }
    // go_interp_text is used here (not go_text) so the scanner can refuse
    // control-flow keywords and let the control_flow rule win instead.
    interpolation: $ => seq('{', $._hole_body, '}'),
    _hole_body: $ => choice($.pipeline, repeat1($._node)),
    pipeline: $ => seq($.go_interp_expr, repeat(seq($.pipe, $.go_interp_expr))),
    go_interp_expr: $ => $.go_interp_text,

    // go_expr is used in expr_attribute and other contexts where
    // control-flow keywords are not valid anyway.
    go_expr: $ => $.go_text,

    // go_spread_expr is used exclusively in spread_attribute: refuses if/for/switch
    // (so conditional_attribute wins when those keywords appear) and stops at
    // depth-0 '...' (so the trailing spread token can be matched literally).
    go_spread_expr: $ => $.go_spread_text,

    // go_block ({{ ... }}) for Go statements
    go_block: $ => seq('{{', $.go_text, '}}'),

    // control_flow: { if/for/switch cond { ... } }
    control_flow: $ => seq(
      '{',
      alias(/if|for|switch/, $.keyword),
      $.go_cond_text,
      $.block,
      repeat($.else_clause),
      '}',
    ),
    block: $ => seq('{', repeat($._node), '}'),
    else_clause: $ => seq(
      alias('else', $.keyword),
      optional(seq(alias('if', $.keyword), $.go_cond_text)),
      $.block,
    ),

    // value_control_flow: if/switch inside an attribute value (class={}, style={}, etc.)
    // Approach (b): structural only when the keyword LEADS the whole attribute value.
    // Limitation: a preceding comma-separated segment (e.g. class={"x", if ...}) causes
    // the scanner to consume the entire value as a single go_interp_text token since
    // go_interp_text only refuses keywords at the very start of a scan, not mid-token.
    // Switch case values are unbraced and remain text within the surrounding
    // switch block; Go highlighting handles their expression content.
    // No scanner.c changes required; existing corpus tests are unaffected.
    value_control_flow: $ => seq(
      alias(/if|switch/, $.keyword),
      $.go_cond_text,
      $.block,
      repeat($.else_clause),
    ),

    // Attributes (including conditional_attribute)
    attribute: $ => choice(
      $.embedded_attribute,
      $.static_attribute,
      $.expr_attribute,
      $.bool_attribute,
      $.spread_attribute,
      $.conditional_attribute,
    ),
    static_attribute: $ => seq($.attribute_name, '=', $.quoted_string),
    embedded_attribute: $ => prec(1, seq(
      $.attribute_name,
      '=',
      choice(
        field('value', $.embedded_js_literal),
        field('value', $.embedded_css_literal),
        seq('{', field('value', $.embedded_js_literal), '}'),
        seq('{', field('value', $.embedded_css_literal), '}'),
      ),
    )),
    embedded_js_literal: $ => seq(
      alias('js', $.embedded_language),
      '`',
      repeat(choice($.embedded_text, $.at_hole)),
      '`',
    ),
    embedded_css_literal: $ => seq(
      alias('css', $.embedded_language),
      '`',
      repeat(choice($.embedded_text, $.at_hole)),
      '`',
    ),
    embedded_text: $ => token(prec(-1, repeat1(choice(/\\`/, /[^`@]+/)))),
    css_composed_value: $ => seq(
      optional($.go_interp_expr),
      $.embedded_css_literal,
      repeat(choice($.style_go_text, $.embedded_css_literal)),
    ),
    // Attribute value: Go expression (pipeline), markup nodes, or a value-form
    // if/switch (value_control_flow).  _attr_hole_body extends _hole_body with
    // value_control_flow so that class={ if cond { "a" } else { "b" } } is parsed
    // structurally; it does NOT affect interpolation {} which keeps using _hole_body.
    expr_attribute: $ => prec(-1, seq($.attribute_name, '=', '{', $._attr_hole_body, '}')),
    _attr_hole_body: $ => choice($.value_control_flow, $.css_composed_value, $._hole_body),
    bool_attribute: $ => prec(-1, $.attribute_name),
    spread_attribute: $ => seq('{', $.go_spread_expr, '...', '}'),
    conditional_attribute: $ => seq(
      '{',
      alias(/if|for/, $.keyword),
      $.go_cond_text,
      '{',
      repeat($.attribute),
      '}',
      optional(seq(
        alias(/else/, $.keyword),
        '{',
        repeat($.attribute),
        '}',
      )),
      '}',
    ),

    attribute_name: $ => /[A-Za-z_@:][A-Za-z0-9_@:.\-]*/,
    quoted_string: $ => choice(seq('"', /[^"]*/, '"'), seq("'", /[^']*/, "'")),

    text: $ => token(prec(-1, /[^<{}>]+/)),

    identifier: $ => /[A-Za-z_][A-Za-z0-9_]*/,
    line_comment: $ => token(seq('//', /.*/)),
    block_comment: $ => token(seq('/*', /[^*]*\*+([^/*][^*]*\*+)*/, '/')),
  },
});
