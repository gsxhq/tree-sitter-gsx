package views


import "github.com/gsxhq/gsx"
component Box(active bool, attrs gsx.Attrs) {
	<div class="base" { attrs... } { if active { class="on" } else { class="off" } }>x</div>
}
