package views

import "github.com/gsxhq/gsx"

component JSPage(u string, a gsx.Attrs, b gsx.Attrs) {
	<a { a... } href=js"javascript:go(@{u})" { b... }>x</a>
}

component CSSPage(u string, a gsx.Attrs, b gsx.Attrs) {
	<form { a... } action=css"color:@{u}" { b... }>x</form>
}

component CondPage(u string, c bool, a gsx.Attrs, b gsx.Attrs) {
	<a { a... } { b... } { if c { href=js"javascript:go(@{u})" } }>x</a>
}
