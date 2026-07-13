package views

import "corpustest/cases/renderers_class_bare_cfarm/pg"

func mkText(s string, valid bool) pg.Text { return pg.Text{String: s, Valid: valid} }

component Tag(val pg.Text, other pg.Text, on bool) {
	<div class={ if on { val } else { other } }>x</div>
}
