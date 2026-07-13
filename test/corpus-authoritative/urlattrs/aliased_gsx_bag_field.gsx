package views

import g "github.com/gsxhq/gsx"

type props struct {
	Attrs g.Attrs
}

component Chip(p props) {
	<a { p.Attrs... }>x</a>
}

component Page() {
	<Chip href="javascript:alert(1)"/>
}
