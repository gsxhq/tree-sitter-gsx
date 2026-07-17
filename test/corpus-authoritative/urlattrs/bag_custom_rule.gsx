package views

import "github.com/gsxhq/gsx"

type widgetProps struct {
	Attrs gsx.Attrs
}

component Widget(p widgetProps) {
	<div { p.Attrs... }>x</div>
}

component Page() {
	<Widget p={widgetProps{Attrs: gsx.Attrs{{Key: "data-href", Value: "javascript:alert(1)"}}}}/>
}
