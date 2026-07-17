package views

import "github.com/gsxhq/gsx"

component Chip(attrs gsx.Attrs) {
	<span a="b" { attrs.Without("id")... }>x</span>
}

component Page() {
	<Chip a="c" id="drop" data-k="v"/>
}
