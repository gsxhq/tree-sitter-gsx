package views

import "github.com/gsxhq/gsx"

component Page() {
	{{ b := gsx.Attrs{{Key: "a", Value: "c"}} }}
	<span a="b" { b... }>x</span>
}
