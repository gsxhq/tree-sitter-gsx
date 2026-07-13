package views

import "github.com/gsxhq/gsx"

type props struct {
	Attrs gsx.Attrs
}

component Chip(p props) {
	<span a="b" data-k="v" { p.Attrs... }>x</span>
}

component Page() {
	<Chip a="c"/>
}
