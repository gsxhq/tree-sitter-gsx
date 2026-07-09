package views

import "github.com/gsxhq/gsx"

component Box(active bool, extra gsx.Attrs) {
	<div { if active { { extra... } } } { attrs... }>x</div>
}
