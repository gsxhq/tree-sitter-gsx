package views

import "github.com/gsxhq/gsx"

component Card(title gsx.Node) { <div class="card" { attrs... }>{title}</div> }

component Page(flag bool) {
	<Card title="Hi" class={ "featured", "active": flag } />
}
