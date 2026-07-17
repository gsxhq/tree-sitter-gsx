package views

import "github.com/gsxhq/gsx"

component Panel(children gsx.Node, attrs gsx.Attrs) {
	<section { attrs... }>{children}</section>
}

component Page() {
	<Panel attrs={{ "a": "1" }} attrs={{ "b": "2" }}/>
}
