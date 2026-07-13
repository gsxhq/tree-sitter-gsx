package views

import "corpustest/cases/renderers_ctx_attr_url/pg"

func mkText(s string, valid bool) pg.Text { return pg.Text{String: s, Valid: valid} }

component Link(danger pg.Text, safe pg.Text) {
	<div>
		<a href={ danger }>bad</a>
		<a href={ safe }>good</a>
	</div>
}
