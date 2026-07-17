package views

import "github.com/gsxhq/gsx"

type dotProps struct {
	Attrs gsx.Attrs
}

component renderDot(p dotProps) {
	<span { p.Attrs... }>*</span>
}

var Dot = func(attrs gsx.Attrs) gsx.Node {
	return renderDot(dotProps{Attrs: attrs})
}

component Wrapper(attrs gsx.Attrs) {
	<Dot class="w-5" { attrs... }/>
}

component Page() {
	<Wrapper class="text-red" data-x="1"/>
}
