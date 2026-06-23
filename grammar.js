module.exports = grammar({
  name: 'gsx',
  externals: $ => [$.go_text, $.raw_text, $.pipe],
  extras: $ => [/\s/, $.line_comment, $.block_comment],
  rules: {
    source_file: $ => repeat($._top_level),
    _top_level: $ => choice($.component_declaration, $.go_chunk),
    go_chunk: $ => $.go_text,

    component_declaration: $ => seq(
      'component', field('name', $.identifier), '(', ')', $.body,
    ),
    body: $ => seq('{', '}'),

    identifier: $ => /[A-Za-z_][A-Za-z0-9_]*/,
    line_comment: $ => token(seq('//', /.*/)),
    block_comment: $ => token(seq('/*', /[^*]*\*+([^/*][^*]*\*+)*/, '/')),
  },
});
