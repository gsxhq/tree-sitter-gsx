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

var Canonical = func(someAttrs gsx.Attrs) gsx.Node {
	return renderBadge(badgeProps{Attrs: someAttrs})
}

component Page() {
	<div>
		<Badge a={myAttrs{{Key: "class", Value: "b"}}}/>
		<Badge/>
		<Canonical someAttrs={{ "class": "c" }}/>
	</div>
}
