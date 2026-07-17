package views

import "github.com/gsxhq/gsx"

type linkProps struct {
	Attrs gsx.Attrs
}

component Link(p linkProps) {
	<a { p.Attrs... }>go</a>
}

component Page() {
	<Link p={linkProps{Attrs: gsx.Attrs{{Key: "href", Value: gsx.RawURL("app://z")}}}}/>
}
