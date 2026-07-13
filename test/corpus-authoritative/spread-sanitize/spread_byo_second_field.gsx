package views

import "github.com/gsxhq/gsx"

type props struct {
	Extra gsx.Attrs
}

component Link(p props) {
	<a { p.Extra... }>click</a>
}
