package views

import "github.com/gsxhq/gsx"

type iconProps struct {
	Attrs gsx.Attrs
}

component renderIcon(p iconProps) {
	<svg { p.Attrs... }>i</svg>
}

component Page(on bool) {
	<div>
		<HomeIcon class={ if on { "a" } else { "b" } }/>
		<HomeIcon class={ if on { "a" } else { "b" } }/>
	</div>
}
