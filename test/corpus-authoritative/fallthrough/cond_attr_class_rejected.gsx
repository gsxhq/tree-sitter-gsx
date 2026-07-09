package views

component Box(active bool) {
	<div { if active { class="on" } } { attrs... }>x</div>
}
