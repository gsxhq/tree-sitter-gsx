package views


import "github.com/gsxhq/gsx"
import "corpustest/cases/renderers_cond_branch_embedded_hole_renderer/pg"

func mkText(s string, valid bool) pg.Text { return pg.Text{String: s, Valid: valid} }

component Field(label string, attrs gsx.Attrs) { <input aria-label={label} { attrs... }/> }

component Page(edit bool, val pg.Text) {
	<Field label="c" { if edit { title=f"Hi @{val}" } } />
}
