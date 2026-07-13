package views

import "corpustest/cases/renderers_style_css_literal_part/pg"

func mkText(s string, valid bool) pg.Text { return pg.Text{String: s, Valid: valid} }

component Tag(val pg.Text, on bool) {
	<div style={ "display:block": on, css`color:@{ val }` }>x</div>
}
