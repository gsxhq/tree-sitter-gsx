package views

import "corpustest/cases/renderers_attr_basic/pg"

func mkText(s string, valid bool) pg.Text { return pg.Text{String: s, Valid: valid} }

component Tag(val pg.Text) {
	<div data-x={ val } title={ val }>ok</div>
}
