package views

import "github.com/gsxhq/gsx"

type iconProps struct {
	Name  string
	Attrs gsx.Attrs
}

component renderIcon(p iconProps) {
	<svg { gsx.Attrs{{Key: "class", Value: "w-5 h-5"}}.Merge(p.Attrs)... }>{p.Name}</svg>
}

component Page() {
	<div>
		<HomeIcon class="h-3 w-3"/>
		<HomeIcon/>
	</div>
}
