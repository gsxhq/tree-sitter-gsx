package views


import "github.com/gsxhq/gsx"
import "corpustest/cases/renderers_fallthrough_ordered_attr/pg"

func mkText(s string, valid bool) pg.Text { return pg.Text{String: s, Valid: valid} }

component Panel(attrs gsx.Attrs) {
	<section { attrs... }>x</section>
}

component Page(val pg.Text) {
	<Panel data-a="1" attrs={{ "data-b": val, "data-c": "9" }} />
}
