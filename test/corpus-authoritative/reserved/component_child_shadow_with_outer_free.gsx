package views

import "github.com/gsxhq/gsx"

component Wrap() {
	<section>{children}</section>
}

component C() {
	<Wrap>
		{{ attrs := gsx.Attrs{{Key: "data-inner", Value: "1"}} }}
		<div { attrs... }>in</div>
	</Wrap>
	<span { attrs... }>out</span>
}
