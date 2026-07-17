package views

import "github.com/gsxhq/gsx"

component Card(title gsx.Node, attrs gsx.Attrs) { <div class="card" { attrs... }>{title}</div> }

component Page(hot bool) {
	<Card title="Hi" { if hot { class="hot" } else { class="cold" } } />
}
