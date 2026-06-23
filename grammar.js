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
    _node: $ => choice(
      $.element,
      $.fragment,
      $.doctype,
      $.html_comment,
      $.content_comment,
      $.interpolation,
      $.control_flow,
      $.go_block,
      $.text,
    ),

    fragment: $ => seq('<>', repeat($._node), '</>'),
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

    // Interpolation: { expr } or { expr? }
    interpolation: $ => seq('{', $._hole_body, optional('?'), '}'),
    _hole_body: $ => $.pipeline,
    pipeline: $ => seq($.go_expr, repeat(seq($.pipe, $.go_expr))),
    go_expr: $ => $.go_text,

    // Task 6 stubs — will be implemented in the next task
    go_block: $ => seq('{{', $.go_text, '}}'),
    control_flow: $ => seq('{', choice(
      seq(/if|for/, $.go_expr, '{', repeat($.attribute), '}',
        optional(seq(/else/, '{', repeat($.attribute), '}'))),
    ), '}'),

    // Attributes
    attribute: $ => choice(
      $.static_attribute,
      $.expr_attribute,
      $.bool_attribute,
      $.spread_attribute,
      $.conditional_attribute,
    ),
    static_attribute: $ => seq($.attribute_name, '=', $.quoted_string),
    expr_attribute: $ => seq($.attribute_name, '=', '{', $.pipeline, optional('?'), '}'),
    bool_attribute: $ => prec(-1, $.attribute_name),
    spread_attribute: $ => seq('{', '...', $.go_expr, '}'),
    conditional_attribute: $ => seq('{', /if|for/, $.go_expr, '{', repeat($.attribute), '}',
      optional(seq(/else/, '{', repeat($.attribute), '}')), '}'),

    attribute_name: $ => /[A-Za-z_@:][A-Za-z0-9_@:.\-]*/,
    quoted_string: $ => choice(seq('"', /[^"]*/, '"'), seq("'", /[^']*/, "'")),

    text: $ => token(prec(-1, /[^<{}>]+/)),

    identifier: $ => /[A-Za-z_][A-Za-z0-9_]*/,
    line_comment: $ => token(seq('//', /.*/)),
    block_comment: $ => token(seq('/*', /[^*]*\*+([^/*][^*]*\*+)*/, '/')),
  },
});
