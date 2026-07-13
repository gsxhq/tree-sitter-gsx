package views

import "github.com/gsxhq/gsx"

component Page() {
	{{ attrs := gsx.Attrs{{Key: "id", Value: "x"}} }}
	<div { attrs... }>hi</div>
}
