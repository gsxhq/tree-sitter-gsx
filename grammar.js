module.exports = grammar({
  name: 'gsx',
  // External tokens (order matches enum in scanner.c):
  //   go_text        — general Go text (top-level, go_block, expr_attribute)
  //   raw_text       — raw HTML text (Task 8)
  //   pipe           — pipe operator (Task 9)
  //   go_cond_text   — Go text for control-flow condition (stops at depth-0 '{')
  //   go_interp_text — Go text inside interpolation { } (refuses if/for/switch)
  externals: $ => [$.go_text, $.raw_text, $.pipe, $.go_cond_text, $.go_interp_text],
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
      $.go_block,
      $.control_flow,
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

    // Interpolation: { expr } or { expr? } or { markup }
    // go_interp_text is used here (not go_text) so the scanner can refuse
    // control-flow keywords and let the control_flow rule win instead.
    interpolation: $ => seq('{', $._hole_body, optional('?'), '}'),
    _hole_body: $ => choice($.pipeline, repeat1($._node)),
    pipeline: $ => seq($.go_interp_expr, repeat(seq($.pipe, $.go_interp_expr))),
    go_interp_expr: $ => $.go_interp_text,

    // go_expr is used in attribute contexts (expr_attribute, spread_attribute)
    // where control-flow keywords are not valid anyway.
    go_expr: $ => $.go_text,

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
      alias(/else/, $.keyword),
      choice($.block, $.control_flow),
    ),

    // Attributes (including conditional_attribute)
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
