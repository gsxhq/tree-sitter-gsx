package views

import "corpustest/cases/renderers_class_part_component/pg"

func mkText(s string, valid bool) pg.Text { return pg.Text{String: s, Valid: valid} }

component Card(title string) { <div { attrs... }>{title}</div> }

component Page(name string) {
	<Card title="hi" class={ mkText(name, true) }/>
}
