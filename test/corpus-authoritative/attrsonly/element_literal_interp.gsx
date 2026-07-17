package views

import "github.com/gsxhq/gsx"

type iconProps struct {
	Name  string
	Attrs gsx.Attrs
}

component renderIcon(p iconProps) {
	<svg { p.Attrs... }>{p.Name}</svg>
}

func icon(name string) func(attrs gsx.Attrs) gsx.Node {
	return func(attrs gsx.Attrs) gsx.Node {
		return renderIcon(iconProps{Name: name, Attrs: attrs})
	}
}

var Home = icon("home")

func wrap(n gsx.Node) gsx.Node { return n }

var cls = "c"
var count = 3

var panel = wrap(<div><Home class={cls}/><b>{count}</b></div>)

component Page() {
	<div>{ panel }</div>
}
