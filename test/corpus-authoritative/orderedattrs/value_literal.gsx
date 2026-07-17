package views

import "github.com/gsxhq/gsx"

component Card(containerAttrs gsx.Attrs, children gsx.Node) {
	<div class="container" { containerAttrs... }>{children}</div>
}

component Page() {
	<Card containerAttrs={{ "data-signals": "{open:false}", "data-text": "$open", "data-a": "z" }}>hi</Card>
}
