package views

import "github.com/gsxhq/gsx"

func drop(attrs []gsx.Attr, key string) []gsx.Attr {
	var out []gsx.Attr
	for _, a := range attrs {
		if a.Key != key {
			out = append(out, a)
		}
	}
	return out
}

func named(name string) func(attrs ...gsx.Attr) gsx.Node {
	return func(attrs ...gsx.Attr) gsx.Node {
		return <svg stroke-width="2" class="size-5" { drop(attrs, "id")... }>{ name }</svg>
	}
}

var Search = named("search")

component Page() {
	<Search id="gone" stroke-width="3" class="size-4"/>
}
