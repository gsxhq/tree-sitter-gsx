package views

import "github.com/gsxhq/gsx"

component CondInterposedStatic(c bool, p gsx.Attrs, q gsx.Attrs) {
	<div { p... } { if c { title="t" } } { q... }>z</div>
}
