package views

component Box(active bool) {
	<div class="base" { attrs... } { if active { class="on" } else { class="off" } }>x</div>
}
