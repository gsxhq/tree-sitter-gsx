package views

import "github.com/gsxhq/gsx"

type widgetProps struct {
	Attrs gsx.Attrs
}

component Widget(p widgetProps) {
	<div { p.Attrs... }>x</div>
}

component Page() {
	<Widget data-href={"javascript:alert(1)"}/>
}
