package views

import "github.com/gsxhq/gsx"

component Chip(attrs gsx.Attrs) {
	<span a="b" data-k="v" { attrs... }>x</span>
}

component Page() {
	<Chip a="c"/>
}
