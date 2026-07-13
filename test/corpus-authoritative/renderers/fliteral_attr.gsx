package views

import "corpustest/cases/renderers_fliteral_attr/pg"

func mkText(s string, valid bool) pg.Text { return pg.Text{String: s, Valid: valid} }

component Tag(val pg.Text) {
	<a href=f`/x/@{val}`>ok</a>
}
