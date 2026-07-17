package views

import "github.com/gsxhq/gsx"

component Card(title gsx.Node, attrs gsx.Attrs) { <div { attrs... }>{title}</div> }

component Page(hot bool, csv string) {
	<Card title="Hi" { if hot { class={ csv |> upper } } } />
}
