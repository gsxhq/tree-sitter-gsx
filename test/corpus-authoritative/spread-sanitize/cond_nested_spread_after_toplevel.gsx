package views

import "github.com/gsxhq/gsx"

component Box(active bool, extra gsx.Attrs) {
	<div { attrs... } { if active { { extra... } } }>x</div>
}
