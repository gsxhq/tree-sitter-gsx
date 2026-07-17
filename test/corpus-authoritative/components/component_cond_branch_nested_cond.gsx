package views

import "github.com/gsxhq/gsx"

component Card(title gsx.Node, attrs gsx.Attrs) { <div class="card" { attrs... }>{title}</div> }

component Page(outer bool, inner bool) {
	<Card title="Hi" { if outer { data-o="1" { if inner { data-i="1" } } } } />
}
