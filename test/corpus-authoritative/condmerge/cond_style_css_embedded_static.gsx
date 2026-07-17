package views


import "github.com/gsxhq/gsx"
component Box(active bool, attrs gsx.Attrs) {
	<div style="color:red" { attrs... } { if active { style=css"margin:0" } }>x</div>
}
