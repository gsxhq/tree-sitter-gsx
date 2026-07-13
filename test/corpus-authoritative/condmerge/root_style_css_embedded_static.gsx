package views

import "github.com/gsxhq/gsx"

component Box(active bool, extra gsx.Attrs) {
	<div style=css"margin:0" { if active { { extra... } } }>x</div>
}
