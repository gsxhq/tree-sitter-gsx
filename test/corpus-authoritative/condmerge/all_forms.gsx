package views

component Box(active bool, v int, hot bool) {
	<div class={ "base", "on": active, switch { case v > 0: "pos" default: "neg" } } { attrs... } { if hot { class="hot" } }>x</div>
}
