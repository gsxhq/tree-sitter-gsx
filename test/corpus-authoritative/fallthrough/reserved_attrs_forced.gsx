package views

import "github.com/gsxhq/gsx"

component Chip(attrs gsx.Attrs) {
	<span data-k="v" { attrs... } a="forced">x</span>
}

component Page() {
	<Chip a="c" data-k="caller" title="t"/>
}
