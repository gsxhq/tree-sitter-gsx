package views

import g "github.com/gsxhq/gsx"

component Chip(attrs g.Attrs) {
	<a { attrs... }>x</a>
}

component Page() {
	<Chip href="javascript:alert(1)"/>
}
