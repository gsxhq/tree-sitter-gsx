package views

import "github.com/gsxhq/gsx"

component Card(containerAttrs gsx.Attrs, children gsx.Node) {
	<div { containerAttrs... }>{children}</div>
}

component Page() {
	<Card
		containerAttrs = {{ "data-signals": "{open:false}", "data-text": "$open" }}
	>
		<p id = "tip" class = {"note"}>hi</p>
	</Card>
}
