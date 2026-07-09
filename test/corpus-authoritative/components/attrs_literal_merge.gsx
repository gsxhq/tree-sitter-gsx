package views

import "github.com/gsxhq/gsx"

component Panel() {
	<section { attrs... }>{children}</section>
}

component Page(extra gsx.Attrs) {
	<Panel data-a="1" attrs={{ "data-b": "2" }} { extra... }>p</Panel>
}
