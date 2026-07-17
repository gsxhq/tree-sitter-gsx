package views

import "github.com/gsxhq/gsx"

type props struct {
	A gsx.Attrs
	B gsx.Attrs
}

component Row(p props) {
	<div { p.A... } { p.B... }>r</div>
}
