package views

import "github.com/gsxhq/gsx"

func f() (string, error) { return "2", nil }

component Panel(attrs gsx.Attrs) {
	<section { attrs... }>x</section>
}

component Page() {
	<Panel data-a="1" attrs={{ "data-b": f() }}/>
}
