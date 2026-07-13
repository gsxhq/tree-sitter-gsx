package views

import "github.com/gsxhq/gsx"

func part() (string, error) { return "red", nil }

component Page(u string, c bool, a gsx.Attrs, b gsx.Attrs) {
	<button { a... } { b... } { if c { onclick=js"do(@{u})" } }>go</button>
	<div { a... } { b... } { if c { style=css"color:@{part()}" } }>x</div>
}
