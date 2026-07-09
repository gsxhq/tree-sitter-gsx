package views

import "github.com/gsxhq/gsx"

component Card(containerAttrs gsx.Attrs) {
	<div class="container" { containerAttrs... }>{children}</div>
}

component Page() {
	<Card container-attrs={{ "data-signals": "{open:false}", "data-text": "$open", "data-a": "z" }}>hi</Card>
}
