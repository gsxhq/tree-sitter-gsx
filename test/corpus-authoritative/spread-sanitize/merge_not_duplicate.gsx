package views

import "github.com/gsxhq/gsx"

component Link() {
	{{ b := gsx.Attrs{{Key: "class", Value: "x"}} }}
	<a class="base" { b... }>click</a>
}
