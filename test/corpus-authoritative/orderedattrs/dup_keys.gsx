package views

import "github.com/gsxhq/gsx"

component Card(dupAttrs gsx.Attrs) {
	<div { dupAttrs... }></div>
}

component Page() {
	<Card dupAttrs={{ "data-x": "1", "data-x": "2" }}/>
}
