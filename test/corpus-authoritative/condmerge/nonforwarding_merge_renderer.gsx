package views

import "corpustest/cases/condmerge_nonforwarding_merge_renderer/pg"

func text(s string, valid bool) pg.Text { return pg.Text{String: s, Valid: valid} }

component Box(on bool, value pg.Text) {
	<div style="color:red" { if on { style={ value } } }>x</div>
}
