package views

import "github.com/gsxhq/gsx"

component StyleCondTwoSpreads(on bool, p gsx.Attrs, q gsx.Attrs) {
	<div { p... } style={ "color:red": on } { q... }>hi</div>
}
