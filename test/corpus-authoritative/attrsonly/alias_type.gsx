package views

import "github.com/gsxhq/gsx"

type Component = func(attrs ...gsx.Attr) gsx.Node

type thingProps struct {
	Label string
	Attrs gsx.Attrs
}

component renderThing(p thingProps) {
	<span { p.Attrs... }>{p.Label}</span>
}

func namedThing(label string) Component {
	return func(attrs ...gsx.Attr) gsx.Node {
		return renderThing(thingProps{Label: label, Attrs: gsx.Attrs(attrs)})
	}
}

var Hello = namedThing("hello")

component Page() {
	<Hello class="w"/>
}
