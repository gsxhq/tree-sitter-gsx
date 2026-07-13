package views

import "github.com/gsxhq/gsx"

func named(name string) func(...gsx.Attr) gsx.Node {
	return func(attrs ...gsx.Attr) gsx.Node {
		return <svg class="size-5" { gsx.Attrs{{Key: "data-x", Value: "1"}}... } { attrs... }>{ name }</svg>
	}
}

var Search = named("search")

component Page() {
	<Search class="size-4" data-x="2"/>
}
