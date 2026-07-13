package views

import "corpustest/cases/renderers_pointer/pg"

func mkText(s string, valid bool) pg.Text { return pg.Text{String: s, Valid: valid} }
func mkTextPtr(s string, valid bool) *pg.Text {
	v := mkText(s, valid)
	return &v
}

component Tag(ptr *pg.Text, val pg.Text) {
	<div>
		<p>{ ptr }</p>
		<p>{ val.String }</p>
	</div>
}
