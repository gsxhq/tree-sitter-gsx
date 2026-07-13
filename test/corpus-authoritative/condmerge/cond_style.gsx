package views

component Box(active bool) {
	<div style="color:red" { attrs... } { if active { style="font-weight:bold" } else { style="font-weight:normal" } }>x</div>
}
