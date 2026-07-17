package views

import "github.com/gsxhq/gsx"

func named(name string) func(attrs ...gsx.Attr) gsx.Node {
	return func(attrs ...gsx.Attr) gsx.Node {
		return <svg stroke-width="2" class="size-5" { attrs... }>{ name }</svg>
	}
}

var Search = named("search")

component Page() {
	<Search stroke-width="3" class="size-4"/>
}
