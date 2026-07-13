package views

import "github.com/gsxhq/gsx"

component InterposedEmbeddedHole(a gsx.Attrs, who string, b gsx.Attrs) {
	<div title=f"Hi @{who}" { a... } { b... }>x</div>
}
