package views

import "github.com/gsxhq/gsx"

component StyleCondLoneSpread(on bool, c bool, x gsx.Attrs) {
	<div style={ "color:red": on } { if c { { x... } } }>hi</div>
}
