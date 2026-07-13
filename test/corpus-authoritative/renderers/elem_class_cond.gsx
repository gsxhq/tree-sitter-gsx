package views

import "corpustest/cases/renderers_elem_class_cond/pg"

func mkText(s string, valid bool) pg.Text { return pg.Text{String: s, Valid: valid} }

component Page(val pg.Text, on bool) {
	<div class={ val: on }>x</div>
}
