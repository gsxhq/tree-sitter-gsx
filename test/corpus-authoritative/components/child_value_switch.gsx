package views

import "github.com/gsxhq/gsx"

component Card(title gsx.Node, attrs gsx.Attrs) { <div class="card" {attrs...}>{title}</div> }

component Page(variant int) {
	<Card title="Hi" class={ "base", switch variant {
	case 1: "primary"
	default: "secondary"
	} } />
}
