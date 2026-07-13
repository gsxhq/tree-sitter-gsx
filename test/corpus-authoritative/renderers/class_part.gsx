package views

import "corpustest/cases/renderers_class_part/pg"

func mkText(s string, valid bool) pg.Text { return pg.Text{String: s, Valid: valid} }

component Tag(val pg.Text) {
	<div class={ val }>x</div>
}
