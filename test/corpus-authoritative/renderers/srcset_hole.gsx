package views

import "corpustest/cases/renderers_srcset_hole/pg"

func mkText(s string, valid bool) pg.Text { return pg.Text{String: s, Valid: valid} }

component Pic(val pg.Text) {
	<img srcset={ val }/>
}
