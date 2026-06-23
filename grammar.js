module.exports = grammar({
  name: 'gsx',
  extras: $ => [/\s/, $.line_comment, $.block_comment],
  rules: {
    source_file: $ => repeat($._top_level),
    _top_level: $ => $.component_declaration,

    // Placeholder until Task 2 wires the scanner: a component with an empty body.
    component_declaration: $ => seq(
      'component', field('name', $.identifier), '(', ')', $.body,
    ),
    body: $ => seq('{', '}'),

    identifier: $ => /[A-Za-z_][A-Za-z0-9_]*/,
    line_comment: $ => token(seq('//', /.*/)),
    block_comment: $ => token(seq('/*', /[^*]*\*+([^/*][^*]*\*+)*/, '/')),
  },
});
