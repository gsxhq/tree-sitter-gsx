package views

import "corpustest/cases/renderers_elem_style_cond/pg"

func mkText(s string, valid bool) pg.Text { return pg.Text{String: s, Valid: valid} }

component Page(val pg.Text, on bool) {
	<div style={ val: on }>x</div>
}
