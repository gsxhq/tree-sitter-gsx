package views

import "github.com/gsxhq/gsx"

component Card(safeAttrs gsx.Attrs) {
	<div { safeAttrs... }></div>
}

component Page() {
	<Card safe-attrs={{ "title": "a\"b", "bad name": "x" }}/>
}
