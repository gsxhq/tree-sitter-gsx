package views

import "github.com/gsxhq/gsx"

type props struct {
	Attrs gsx.Attrs
}

component Chip(p props) {
	<span a="b" { p.Attrs.Without("id")... }>x</span>
}

component Page() {
	<Chip a="c" id="drop" data-k="v"/>
}
