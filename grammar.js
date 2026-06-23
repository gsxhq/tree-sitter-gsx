module.exports = grammar({
  name: 'gsx',
  externals: $ => [$.go_text, $.raw_text, $.pipe],
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
    _paren_go: $ => token(prec(-1, /[^()]+/)),

    body: $ => seq('{', repeat($._node), '}'),
    _node: $ => choice($.element, $.text),

    element: $ => choice(
      $.self_closing_element,
      seq($.start_tag, repeat($._node), $.end_tag),
    ),
    start_tag: $ => seq('<', field('name', $.tag_name), repeat($.attribute), '>'),
    end_tag: $ => seq('</', $.tag_name, '>'),
    self_closing_element: $ => seq('<', field('name', $.tag_name), repeat($.attribute), '/>'),
    tag_name: $ => /[A-Za-z][A-Za-z0-9.\-]*/,

    // Static attribute only for now (expr/bool/etc. in Task 5).
    attribute: $ => seq($.attribute_name, optional(seq('=', $.quoted_string))),
    attribute_name: $ => /[A-Za-z_@:][A-Za-z0-9_@:.\-]*/,
    quoted_string: $ => choice(seq('"', /[^"]*/, '"'), seq("'", /[^']*/, "'")),

    text: $ => token(prec(-1, /[^<{}>]+/)),

    identifier: $ => /[A-Za-z_][A-Za-z0-9_]*/,
    line_comment: $ => token(seq('//', /.*/)),
    block_comment: $ => token(seq('/*', /[^*]*\*+([^/*][^*]*\*+)*/, '/')),
  },
});
