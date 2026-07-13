package views

import "github.com/gsxhq/gsx"

component InterposedClassStyle(p gsx.Attrs, q gsx.Attrs) {
	<div { p... } class="x" style="color:red" { q... }>y</div>
}
