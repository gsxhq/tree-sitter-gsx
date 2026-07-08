const goGrammar = require('tree-sitter-go/grammar.js');

module.exports = grammar(goGrammar, {
  name: 'gsx',

  rules: {
    // Redeclares Go's _expression alternative list (rule NAMES only —
    // each rule's own body stays inherited/untouched from goGrammar)
    // plus element/fragment. Verify this list against tree-sitter-go's
    // _expression rule on every upstream version bump.
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
    ),

    element: $ => choice(
      seq('<', field('name', $.identifier), repeat($.attribute), '/>'),
      seq(
        '<', field('open_name', $.identifier), repeat($.attribute), '>',
        repeat($._child),
        '</', field('close_name', $.identifier), '>',
      ),
    ),

    attribute: $ => choice(
      $.static_attribute,
      $.expr_attribute,
      $.bool_attribute,
      $.spread_attribute,
      $.conditional_attribute,
    ),

    attribute_name: $ => /[A-Za-z_@:][A-Za-z0-9_@:.\-]*/,

    static_attribute: $ => seq(field('name', $.attribute_name), '=', field('value', $._string_literal)),

    // Reuses 2a's `hole` rule directly for the value — name={ expr }.
    expr_attribute: $ => prec(-1, seq(field('name', $.attribute_name), '=', field('value', $.hole))),

    bool_attribute: $ => prec(-1, field('name', $.attribute_name)),

    spread_attribute: $ => seq('{', field('value', $._expression), '...', '}'),

    // Condition shape mirrors 2a's control_flow (reuses Go's own for_clause/
    // range_clause, not reimplemented), applied to a repeated ATTRIBUTE list
    // instead of a repeated CHILD list.
    conditional_attribute: $ => seq(
      '{',
      alias(choice('if', 'for'), $.keyword),
      field('condition', choice($._expression, $.for_clause, $.range_clause)),
      '{', repeat($.attribute), '}',
      optional(seq(
        alias('else', $.keyword),
        '{', repeat($.attribute), '}',
      )),
      '}',
    ),

    // '<>'/'</>' as single atomic tokens (not seq('<', '>')) — matters:
    // a naive two-literal seq lets the parser fork into element's
    // '<' + identifier path first and error out on '>' instead of
    // choosing fragment.
    fragment: $ => seq(
      token(seq('<', '>')),
      repeat($._child),
      token(seq('<', '/', '>')),
    ),

    _child: $ => choice(
      $.element,
      $.fragment,
      $.hole,
      $.control_flow,
      $.text,
    ),

    // Hole body is a real Go expression — element/fragment already
    // included via _expression (Phase 1). No separate node-sequence
    // alternative: every real standalone-hole usage in the legacy corpus
    // is a single node, and elements are already Go expressions.
    hole: $ => seq('{', $._expression, '}'),

    // Condition reuses Go's own for_statement condition shape (plain
    // expr, or a real for_clause/range_clause for `for`) — inherited
    // from the base grammar unmodified, not reimplemented. The block
    // body is markup children, not Go statements, so control_flow can't
    // reuse Go's native if_statement/for_statement wholesale (their
    // block holds $._statement).
    control_flow: $ => seq(
      '{',
      alias(choice('if', 'for', 'switch'), $.keyword),
      field('condition', choice($._expression, $.for_clause, $.range_clause)),
      '{', repeat($._child), '}',
      repeat($.else_clause),
      '}',
    ),

    else_clause: $ => seq(
      alias('else', $.keyword),
      optional(seq(alias('if', $.keyword), field('condition', $._expression))),
      '{', repeat($._child), '}',
    ),

    text: $ => token(prec(-1, /[^<{}]+/)),
  },
});
