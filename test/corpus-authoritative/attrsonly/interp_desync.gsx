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

component Widget(label string, n int) {
	<div>
		<span>{label}</span>
		<Home class={label}/>
		<Home class={label}/>
		<b>{n}</b>
	</div>
}

component Page() {
	<Widget label="hi" n={7}/>
}
