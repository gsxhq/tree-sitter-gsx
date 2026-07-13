package views

import "corpustest/cases/renderers_component_arg_negative/pg"

func mkText(s string, valid bool) pg.Text { return pg.Text{String: s, Valid: valid} }

component Child(val pg.Text) {
	<span>{ val.String }</span>
}

component Parent(val pg.Text) {
	<Child val={val}/>
}
