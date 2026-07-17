package views


import "github.com/gsxhq/gsx"
component Box(active bool, c string, attrs gsx.Attrs) {
	<div style="color:red" { attrs... } { if active { style=css"margin:@{c}" } }>x</div>
}
