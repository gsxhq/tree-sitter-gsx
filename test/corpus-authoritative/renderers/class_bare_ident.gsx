package views

import "corpustest/cases/renderers_class_bare_ident/pg"

func mkText(s string, valid bool) pg.Text { return pg.Text{String: s, Valid: valid} }

type box struct{ Cls pg.Text }

func mkBox(s string, valid bool) box { return box{Cls: mkText(s, valid)} }

component Card(title string) { <div { attrs... }>{title}</div> }

component Page(val pg.Text, b box) {
	<Card title="hi" class={ val, b.Cls }/>
}
