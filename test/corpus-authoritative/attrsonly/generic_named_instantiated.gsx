package views

import "github.com/gsxhq/gsx"

type iconProps struct {
	Name  string
	Attrs gsx.Attrs
}

component renderIcon(p iconProps) {
	<svg { p.Attrs... }>{p.Name}</svg>
}

type Component[T any] func(attrs ...gsx.Attr) gsx.Node

var Y Component[int] = func(attrs ...gsx.Attr) gsx.Node {
	return renderIcon(iconProps{Name: "y", Attrs: gsx.Attrs(attrs)})
}

component Page() {
	<Y class="c"/>
}
