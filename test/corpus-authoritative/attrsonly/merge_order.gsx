package views

import "github.com/gsxhq/gsx"

type boxProps struct {
	Attrs gsx.Attrs
}

component renderBox(p boxProps) {
	<div { p.Attrs... }>box</div>
}

func Box(attrs gsx.Attrs) gsx.Node {
	return renderBox(boxProps{Attrs: attrs})
}

component Page(on bool, extra gsx.Attrs) {
	<Box data-a="1" attrs={{ "data-z": "9" }} { extra... } { if on { data-c="3" } } data-b="2"/>
}
