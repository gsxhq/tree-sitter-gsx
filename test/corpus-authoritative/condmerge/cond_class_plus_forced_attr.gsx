package views


import "github.com/gsxhq/gsx"
component Box(a bool, attrs gsx.Attrs) {
	<div class="base" { attrs... } { if a { class="on" aria-current="page" } }>x</div>
}
