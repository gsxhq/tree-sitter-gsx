package views

import (
	"github.com/gsxhq/gsx"

	"corpustest/cases/renderers_fallthrough_attr/pg"
)

func mkText(s string, valid bool) pg.Text { return pg.Text{String: s, Valid: valid} }

component Card(title gsx.Node) { <div { attrs... }>{title}</div> }

component Page(val pg.Text) {
	<Card title="Hi" data-x={ val } />
}
