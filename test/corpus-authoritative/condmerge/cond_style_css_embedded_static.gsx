package views

component Box(active bool) {
	<div style="color:red" { attrs... } { if active { style=css"margin:0" } }>x</div>
}
