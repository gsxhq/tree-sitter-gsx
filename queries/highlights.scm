; Keywords
"component" @keyword
(keyword) @keyword

; Value-form if/switch inside attribute values (class={}, style={}, etc.)
; if/switch/else keywords are (keyword) nodes, already captured above.
; Note: case/default labels inside switch arms are text nodes under approach (b)
; and are not individually highlighted — see grammar.js value_control_flow comment.
(value_control_flow (keyword) @keyword)

; Component declaration name → function
(component_declaration name: (identifier) @function)

; Element tag: lowercase/hyphenated, NO dot
((tag_name) @tag
  (#match? @tag "^[a-z][a-z0-9-]*$"))
; Component tag: uppercase-initial
((tag_name) @type
  (#match? @type "^[A-Z]"))
; Component tag: dotted (e.g. nav.Link, ui.Button)
((tag_name) @type
  (#match? @type "\\."))

; Attributes and strings
(attribute_name) @attribute
(quoted_string) @string
(embedded_language) @keyword
(embedded_text) @string.special

; Operators
(pipe) @operator
"..." @operator

; Punctuation — special (holes, go-blocks, go-statement blocks)
"{" @punctuation.special
"}" @punctuation.special
"@{" @punctuation.special
"{{" @punctuation.special
"}}" @punctuation.special

; Fragments — treated as tags
"<>" @tag
"</>" @tag

; Angle-bracket punctuation
"<" @punctuation.bracket
">" @punctuation.bracket
"/>" @punctuation.bracket
"</" @punctuation.bracket

; Comments
(line_comment) @comment
(block_comment) @comment
(html_comment) @comment
(content_comment) @comment

; Doctype
(doctype) @keyword
