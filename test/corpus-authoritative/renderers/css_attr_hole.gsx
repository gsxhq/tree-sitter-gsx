package views

import (
	"corpustest/cases/renderers_css_attr_hole/pg"
	"github.com/gsxhq/gsx"
)

func mkText(s string, valid bool) pg.Text { return pg.Text{String: s, Valid: valid} }

component Tag(val pg.Text, a gsx.Attrs, b gsx.Attrs) {
	<div data-style=css`color:@{ val }`>inline</div>
	<div { a... } data-style=css`color:@{ val }` { b... }>fold</div>
}
