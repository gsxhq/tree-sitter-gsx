package views

import "github.com/gsxhq/gsx"

component Link(extra gsx.Attrs) {
	<a href="/base" { attrs... } { extra... }>x</a>
}
