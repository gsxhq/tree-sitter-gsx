package views


import "github.com/gsxhq/gsx"
component Box(active bool, v int, hot bool, attrs gsx.Attrs) {
	<div class={ "base", "on": active, switch { case v > 0: "pos" default: "neg" } } { attrs... } { if hot { class="hot" } }>x</div>
}
