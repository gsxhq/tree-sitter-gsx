package views

import "github.com/gsxhq/gsx"

component Button(attrs gsx.Attrs) {
	<div {attrs...}></div>
}

component Page() {
	<Button full-width aria-label="Close" data-id="7"/>
}
