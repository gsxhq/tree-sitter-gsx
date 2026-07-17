package views

import "github.com/gsxhq/gsx"

component Card(title gsx.Node, attrs gsx.Attrs) { <div class="card" { attrs... }>{title}</div> }

component Page(name string) {
	<Card title="Hi" data-x={ name |> upper } />
}
