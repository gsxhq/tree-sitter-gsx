; Go leaf tokens — inject the Go grammar for syntax highlighting.
; go_text: Go source in top-level go_chunk and go_expr bodies.
((go_text) @injection.content
 (#set! injection.language "go"))

; go_interp_text: Go source inside interpolation expressions (@{...}) and expr_attributes.
((go_interp_text) @injection.content
 (#set! injection.language "go"))

; go_spread_text: Go source inside spread/splat attribute { expr... }.
((go_spread_text) @injection.content
 (#set! injection.language "go"))

; go_cond_text: Go source in conditional / control-flow attribute conditions.
((go_cond_text) @injection.content
 (#set! injection.language "go"))

; parameter_list and receiver: Go func signatures (parens included — acceptable for highlighting).
((parameter_list) @injection.content
 (#set! injection.language "go"))

((receiver) @injection.content
 (#set! injection.language "go"))

; <script> raw text runs → JavaScript, stitched across @{ } holes.
(raw_element
  name: (tag_name) @_n
  (raw_text) @injection.content
  (#match? @_n "^[Ss][Cc][Rr][Ii][Pp][Tt]$")
  (#set! injection.language "javascript")
  (#set! injection.combined true))

; <style> raw text runs → CSS, stitched across @{ } holes.
(raw_element
  name: (tag_name) @_n
  (raw_text) @injection.content
  (#match? @_n "^[Ss][Tt][Yy][Ll][Ee]$")
  (#set! injection.language "css")
  (#set! injection.combined true))

; DEFERRED: JS/CSS-context attribute injection (x-data="...", style="...") — not implemented in v1.
