package views


import "github.com/gsxhq/gsx"
import "corpustest/cases/renderers_class_part_component/pg"

func mkText(s string, valid bool) pg.Text { return pg.Text{String: s, Valid: valid} }

component Card(title string, attrs gsx.Attrs) { <div { attrs... }>{title}</div> }

component Page(name string) {
	<Card title="hi" class={ mkText(name, true) }/>
}
