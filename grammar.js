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
      seq('<', field('name', $.identifier), '/>'),
      seq(
        '<', field('open_name', $.identifier), '>',
        optional(field('body', $.element_text)),
        '</', field('close_name', $.identifier), '>',
      ),
    ),

    // '<>'/'</>' as single atomic tokens (not seq('<', '>')) — matters:
    // a naive two-literal seq lets the parser fork into element's
    // '<' + identifier path first and error out on '>' instead of
    // choosing fragment.
    fragment: $ => seq(
      token(seq('<', '>')),
      optional(field('body', $.element_text)),
      token(seq('<', '/', '>')),
    ),

    element_text: $ => token(prec(-1, /[^<]+/)),
  },
});
