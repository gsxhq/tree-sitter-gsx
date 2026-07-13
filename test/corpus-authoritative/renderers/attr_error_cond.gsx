package views

import (
	"github.com/gsxhq/gsx"

	"corpustest/cases/renderers_attr_error_cond/pg"
)

func mkText(s string, valid bool) pg.Text { return pg.Text{String: s, Valid: valid} }

component Card(title gsx.Node) { <div { attrs... }>{title}</div> }

component Page(hot bool, val pg.Text) {
	<Card title="Hi" { if hot { data-x={ val } } } />
}
