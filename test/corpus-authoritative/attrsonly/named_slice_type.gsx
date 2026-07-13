package views

import "github.com/gsxhq/gsx"

type myAttrs []gsx.Attr

type badgeProps struct {
	Attrs gsx.Attrs
}

component renderBadge(p badgeProps) {
	<span { p.Attrs... }>badge</span>
}

var Badge = func(a myAttrs) gsx.Node {
	return renderBadge(badgeProps{Attrs: gsx.Attrs(a)})
}

component Page() {
	<div>
		<Badge class="b"/>
		<Badge/>
	</div>
}
