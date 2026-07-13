package views

component Box(active bool, c string) {
	<div style="color:red" { attrs... } { if active { style=css"margin:@{c}" } }>x</div>
}
