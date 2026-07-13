package views

import (
	"corpustest/cases/renderers_js_attr_hole/pg"
	"github.com/gsxhq/gsx"
)

func mkText(s string, valid bool) pg.Text { return pg.Text{String: s, Valid: valid} }

component Tag(val pg.Text, a gsx.Attrs, b gsx.Attrs) {
	<button @click=js`save(@{ val })`>inline</button>
	<button { a... } @click=js`save(@{ val })` { b... }>fold</button>
}
