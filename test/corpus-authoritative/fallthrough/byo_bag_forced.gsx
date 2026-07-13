package views

import "github.com/gsxhq/gsx"

type props struct {
	Attrs gsx.Attrs
}

component Chip(p props) {
	<span data-k="v" { p.Attrs... } a="forced">x</span>
}

component Page() {
	<Chip a="c" data-k="caller" title="t"/>
}
