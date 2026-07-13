package views

component Box(a bool) {
	<div class="base" { attrs... } { if a { class="on" aria-current="page" } }>x</div>
}
