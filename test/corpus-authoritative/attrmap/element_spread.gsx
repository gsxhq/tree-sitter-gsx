package views

import "github.com/gsxhq/gsx"

component Card(bag gsx.Attrs) {
	<div { bag... }>x</div>
}

component Page() {
	<Card bag={gsx.AttrMap{"data-b": "2", "data-a": "1"}.ToAttrs()}/>
}
