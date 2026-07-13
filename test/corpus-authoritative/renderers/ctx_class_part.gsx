package views

import "corpustest/cases/renderers_ctx_class_part/pg"

func mkText(s string, valid bool) pg.Text { return pg.Text{String: s, Valid: valid} }

component Card(title string) { <div { attrs... }>{title}</div> }

component Page(name pg.Text) {
	<Card title="hi" class={ name }/>
}
