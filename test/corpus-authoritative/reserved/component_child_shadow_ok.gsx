package views

import "github.com/gsxhq/gsx"

component Wrap() {
	<section>{children}</section>
}

component Page() {
	<Wrap>
		{{ attrs := gsx.Attrs{{Key: "id", Value: "x"}} }}
		<span { attrs... }>hi</span>
	</Wrap>
}
