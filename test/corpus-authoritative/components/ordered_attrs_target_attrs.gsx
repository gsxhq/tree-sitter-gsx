package p

import "github.com/gsxhq/gsx"

component Panel(Attrs gsx.Attrs, children gsx.Node, attrs gsx.Attrs) {
	<section { attrs... }><i { Attrs... }></i>{children}</section>
}

component Home() {
	<Panel attrs={{ "data-a": "1" }} Attrs={{ "data-b": "2" }}>x</Panel>
}
