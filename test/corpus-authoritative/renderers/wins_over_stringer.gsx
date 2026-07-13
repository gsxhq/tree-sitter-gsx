package views

import "corpustest/cases/renderers_wins_over_stringer/pg"

func mkText(s string, valid bool) pg.Text { return pg.Text{Value: s, Valid: valid} }

component Tag(val pg.Text) {
	<div>{ val }</div>
}
