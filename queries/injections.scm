; injections.scm — unified Go+gsx grammar.
;
; Go itself is NATIVE in this grammar (not injected), so there is no Go
; injection. These injections color the SUBLANGUAGE bodies:
;   • <script> raw-text  → javascript
;   • <style>  raw-text  → css
;   • js`…` literal body  → javascript
;   • css`…` literal body → css
; (Interpolation holes inside them — @{ … } / { … } — are parsed by the gsx
; grammar itself and are not part of the injected content ranges.)

; <script> … </script> raw body → JavaScript
((raw_element
   (tag_name) @_tag
   (raw_text) @injection.content)
 (#match? @_tag "^[Ss][Cc][Rr][Ii][Pp][Tt]$")
 (#set! injection.language "javascript")
 (#set! injection.combined))

; <style> … </style> raw body → CSS
((raw_element
   (tag_name) @_tag
   (raw_text) @injection.content)
 (#match? @_tag "^[Ss][Tt][Yy][Ll][Ee]$")
 (#set! injection.language "css")
 (#set! injection.combined))

; js`…` literal text → JavaScript
((embedded_js_literal
   (embedded_text) @injection.content)
 (#set! injection.language "javascript")
 (#set! injection.combined))
((embedded_js_literal
   (embedded_text_dq) @injection.content)
 (#set! injection.language "javascript")
 (#set! injection.combined))

; css`…` literal text → CSS
((embedded_css_literal
   (embedded_text) @injection.content)
 (#set! injection.language "css")
 (#set! injection.combined))
((embedded_css_literal
   (embedded_text_dq) @injection.content)
 (#set! injection.language "css")
 (#set! injection.combined))
