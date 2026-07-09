; highlights.scm — unified Go+gsx grammar.
;
; Go is NATIVE in this grammar (not injected), so this query colors both Go
; tokens and gsx-specific nodes in one self-contained file. The Go section is
; adapted from tree-sitter-go's own highlights.scm; the gsx section follows
; and, because later patterns win in Neovim's highlighter, overrides the
; generic Go captures where a node plays a gsx-specific role (e.g. an element
; name is an `identifier` that should read as a tag, not a variable).

; ─────────────────────────────────────────────────────────────────────────
; Go (base) — adapted from tree-sitter-go/queries/highlights.scm
; ─────────────────────────────────────────────────────────────────────────

; Function calls
(call_expression
  function: (identifier) @function)
(call_expression
  function: (identifier) @function.builtin
  (#match? @function.builtin "^(append|cap|close|complex|copy|delete|imag|len|make|new|panic|print|println|real|recover)$"))
(call_expression
  function: (selector_expression
    field: (field_identifier) @function.method))

; Function definitions
(function_declaration
  name: (identifier) @function)
(method_declaration
  name: (field_identifier) @function.method)

; Identifiers
(type_identifier) @type
(field_identifier) @property
(identifier) @variable

; Operators
[
  "--" "-" "-=" ":=" "!" "!=" "..." "*" "*=" "/" "/=" "&" "&&" "&="
  "%" "%=" "^" "^=" "+" "++" "+=" "<-" "<" "<<" "<<=" "<=" "=" "=="
  ">" ">=" ">>" ">>=" "|" "|=" "||" "~"
] @operator

; Keywords
[
  "break" "case" "chan" "const" "continue" "default" "defer" "else"
  "fallthrough" "for" "func" "go" "goto" "if" "import" "interface" "map"
  "package" "range" "return" "select" "struct" "switch" "type" "var"
] @keyword

; Literals
[
  (interpreted_string_literal)
  (raw_string_literal)
  (rune_literal)
] @string
(escape_sequence) @string.escape
[
  (int_literal)
  (float_literal)
  (imaginary_literal)
] @number
[
  (true)
  (false)
  (nil)
  (iota)
] @constant.builtin
(comment) @comment

; ─────────────────────────────────────────────────────────────────────────
; gsx (overrides + additions)
; ─────────────────────────────────────────────────────────────────────────

; `component` declaration — the keyword, and the name reads like a function def.
(component_declaration
  name: (identifier) @function)
"component" @keyword

; Element tags: <div>…</div>, <Icon/>. The name is an identifier; color it as a
; tag. A capitalized/dotted name is a component invocation — still tag-colored.
(element
  name: (identifier) @tag)
(element
  open_name: (identifier) @tag)
(element
  close_name: (identifier) @tag)

; Markup tag punctuation. (Fragment delimiters <>/</> are single composite
; tokens, not queryable as string literals, so they're left uncolored.)
[
  "<"
  ">"
  "/>"
  "</"
] @tag.delimiter

; Attributes.
(attribute_name) @attribute
(bool_attribute (attribute_name) @attribute)

; `{ … }` hole / control-flow / composable braces read as special punctuation.
[
  "{"
  "}"
] @punctuation.special

; Control-flow / value-form keyword nodes (aliased to `keyword` in the grammar:
; if/for/switch/else inside control_flow, conditional_attribute, etc.).
(keyword) @keyword.conditional

; Embedded f`…` / js`…` / css`…` literals.
(embedded_language) @keyword
[
  (embedded_text)
  (embedded_text_dq)
] @string.special
; @{ … } interpolation hole markers inside embedded literals.
"@{" @punctuation.special

; Markup text content (between tags) — plain literal text, left uncolored so it
; reads as prose rather than code.
(text) @none
