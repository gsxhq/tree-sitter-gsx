package views

import "corpustest/cases/renderers_style_part/pg"

func mkText(s string, valid bool) pg.Text { return pg.Text{String: s, Valid: valid} }

component Tag(val pg.Text) {
	<div style={ val }>x</div>
}
