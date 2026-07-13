package views

import (
	"corpustest/cases/multispread_cond_class_part_renderer/pg"

	"github.com/gsxhq/gsx"
)

func mkText(s string, valid bool) pg.Text { return pg.Text{String: s, Valid: valid} }

component Page(val pg.Text, on bool, a gsx.Attrs, b gsx.Attrs) {
	<div class={ val: on } { a... } { b... }>x</div>
}
