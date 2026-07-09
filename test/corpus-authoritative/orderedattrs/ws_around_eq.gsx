package views

import "github.com/gsxhq/gsx"

component Card(containerAttrs gsx.Attrs) {
	<div { containerAttrs... }>{children}</div>
}

component Page() {
	<Card
		container-attrs = {{ "data-signals": "{open:false}", "data-text": "$open" }}
	>
		<p id = "tip" class = {"note"}>hi</p>
	</Card>
}
