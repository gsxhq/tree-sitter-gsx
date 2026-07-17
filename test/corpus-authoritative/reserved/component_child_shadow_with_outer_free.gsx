package views

import "github.com/gsxhq/gsx"

component Wrap(children gsx.Node) {
	<section>{children}</section>
}

component C() {
	{{ attrs := gsx.Attrs{{Key: "data-outer", Value: "9"}} }}
	<Wrap>
		{{ attrs := gsx.Attrs{{Key: "data-inner", Value: "1"}} }}
		<div { attrs... }>in</div>
	</Wrap>
	<span { attrs... }>out</span>
}
