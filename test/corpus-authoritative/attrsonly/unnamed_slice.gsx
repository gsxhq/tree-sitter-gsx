package views

import "github.com/gsxhq/gsx"

type badgeProps struct {
	Attrs gsx.Attrs
}

component renderBadge(p badgeProps) {
	<span { p.Attrs... }>badge</span>
}

func Badge(attrs []gsx.Attr) gsx.Node {
	return renderBadge(badgeProps{Attrs: gsx.Attrs(attrs)})
}

component Page() {
	<div>
		<Badge class="b"/>
		<Badge/>
	</div>
}
