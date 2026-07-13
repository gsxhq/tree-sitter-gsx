package views

import "github.com/gsxhq/gsx"

component Box(active bool, c string, extra gsx.Attrs) {
	<div style=css"margin:@{c}" { if active { { extra... } } }>x</div>
}
