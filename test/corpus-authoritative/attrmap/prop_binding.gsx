package views

import "github.com/gsxhq/gsx"

component Card(bag gsx.Attrs) {
	<div { bag... }>x</div>
}

component Page() {
	<Card bag={gsx.AttrMap{"id": "x", "class": "c"}.ToAttrs()}/>
}
