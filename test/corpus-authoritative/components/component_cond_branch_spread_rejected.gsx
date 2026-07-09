package views

import "github.com/gsxhq/gsx"

component Card(title gsx.Node) { <div class="card">{title}</div> }

component Page(hot bool, extra gsx.Attrs) {
	<Card title="Hi" { if hot { { extra... } } } />
}
