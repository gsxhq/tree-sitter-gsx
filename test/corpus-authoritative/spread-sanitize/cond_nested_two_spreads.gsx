package views

import "github.com/gsxhq/gsx"

component Bad(c bool, d bool, x gsx.Attrs, y gsx.Attrs) {
	<a { if c { { x... } } } { if d { { y... } } }>hi</a>
}
