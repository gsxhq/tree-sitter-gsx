package views

import "github.com/gsxhq/gsx"

func mkBag(h string) gsx.Attrs { return gsx.Attrs{{Key: "href", Value: h}} }

component Link(userHref string) {
	<a { mkBag(userHref)... }>click</a>
}
