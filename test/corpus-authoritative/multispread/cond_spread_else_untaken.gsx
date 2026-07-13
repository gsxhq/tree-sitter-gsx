package views

import "github.com/gsxhq/gsx"

component CondSpreadElse(c bool, base gsx.Attrs, x gsx.Attrs, y gsx.Attrs) {
	<div { base... } { if c { { x... } } else { { y... } } }>z</div>
}
