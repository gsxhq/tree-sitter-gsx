package views

import "github.com/gsxhq/gsx"

type pillProps struct {
	Attrs gsx.Attrs
}

component renderPill(p pillProps) {
	<span { p.Attrs... }>pill</span>
}

func Pill(attrs gsx.Attrs) gsx.Node {
	return renderPill(pillProps{Attrs: attrs})
}

component Page() {
	<div>
		<Pill class="p"/>
		<Pill/>
	</div>
}
