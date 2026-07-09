package views

import "github.com/gsxhq/gsx"

component Card(toggleAttrs gsx.Attrs) {
	<div { toggleAttrs... }></div>
}

component Page() {
	<Card toggle-attrs={{ "data-show": true, "data-hide": false }}/>
}
