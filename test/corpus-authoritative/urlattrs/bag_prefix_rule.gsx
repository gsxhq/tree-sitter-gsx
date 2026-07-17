package views

import "github.com/gsxhq/gsx"

type navProps struct {
	Attrs gsx.Attrs
}

component Nav(p navProps) {
	<div { p.Attrs... }>x</div>
}

component Page() {
	<Nav p={navProps{Attrs: gsx.Attrs{{Key: "data-url-next", Value: "javascript:alert(1)"}, {Key: "data-x", Value: "keep"}}}}/>
}
