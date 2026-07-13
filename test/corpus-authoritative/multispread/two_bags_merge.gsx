package views

import "github.com/gsxhq/gsx"

component Link() {
	{{ b1 := gsx.Attrs{{Key: "href", Value: "/a"}} }}
	{{ b2 := gsx.Attrs{{Key: "id", Value: "x"}} }}
	<a { b1... } { b2... }>click</a>
}
