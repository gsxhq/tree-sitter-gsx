package views


import "github.com/gsxhq/gsx"
component Box(active bool, attrs gsx.Attrs) {
	<div style="color:red" { attrs... } { if active { style="font-weight:bold" } else { style="font-weight:normal" } }>x</div>
}
