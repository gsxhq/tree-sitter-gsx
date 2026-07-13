package views

import "corpustest/cases/renderers_valuecf_arm/pg"

func mkText(s string, valid bool) pg.Text { return pg.Text{String: s, Valid: valid} }

component Tag(val pg.Text, on bool) {
	<div class={ if on { val } else { "off" } }>x</div>
}
