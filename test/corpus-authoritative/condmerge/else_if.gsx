package views

component Box(a bool, b bool) {
	<div class="base" { attrs... } { if a { class="x" } else if b { class="y" } else { class="z" } }>x</div>
}
