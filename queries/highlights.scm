; Keywords
"component" @keyword
(keyword) @keyword

; Component declaration name → function
(component_declaration name: (identifier) @function)

; Element tag (lowercase start) → tag; component/dotted tag (uppercase or dotted) → type
((tag_name) @tag
  (#match? @tag "^[a-z]"))
((tag_name) @type
  (#match? @tag "^[A-Z]"))
((tag_name) @type
  (#match? @tag "\\."))

; Attributes and strings
(attribute_name) @attribute
(quoted_string) @string

; Operators
(pipe) @operator
"?" @operator

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
