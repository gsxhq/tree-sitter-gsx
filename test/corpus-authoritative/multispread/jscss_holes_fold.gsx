package views

import "github.com/gsxhq/gsx"

component Page(u string, color string, a gsx.Attrs, b gsx.Attrs) {
	<button { a... } onclick=js"do(@{u})" { b... }>go</button>
	<div { a... } style=css"color:@{color}" { b... }>x</div>
}
