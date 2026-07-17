package views


import "github.com/gsxhq/gsx"
component Box(a bool, b bool, attrs gsx.Attrs) {
	<div class="base" { attrs... } { if a { class="x" } else if b { class="y" } else { class="z" } }>x</div>
}
