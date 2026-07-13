package views

import "corpustest/cases/renderers_elem_class_cond_alignment/pg"

func mkText(s string, valid bool) pg.Text { return pg.Text{String: s, Valid: valid} }

component Page(before string, val pg.Text, on bool, after string) {
	<span>{before}</span>
	<div class={ val: on }>x</div>
	<span>{after}</span>
}
