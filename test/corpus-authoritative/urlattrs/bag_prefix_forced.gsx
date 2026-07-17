package views

import "github.com/gsxhq/gsx"

type navProps struct {
	Attrs gsx.Attrs
}

component Nav(p navProps) {
	<a { p.Attrs... } data-url-go="/forced">x</a>
}

component Page() {
	<Nav p={navProps{Attrs: gsx.Attrs{{Key: "data-url-go", Value: "javascript:alert(1)"}, {Key: "data-url-keep", Value: "/safe"}}}}/>
}
