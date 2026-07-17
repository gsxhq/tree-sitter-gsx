package views

import "github.com/gsxhq/gsx"

component Panel(attrs gsx.Attrs) {
	<section { attrs... }>p</section>
}

component Page(extra gsx.Attrs) {
	<Panel data-pre="root" { extra... } data-v="root"/>
}
