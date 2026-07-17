package views

import "github.com/gsxhq/gsx"

component Card(title gsx.Node, attrs gsx.Attrs) { <div class="card" { attrs... }>{title}</div> }

component Page(extra gsx.Attrs) {
	<Card title="Hi" { extra... } />
}
