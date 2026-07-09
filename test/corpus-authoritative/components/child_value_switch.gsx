package views

import "github.com/gsxhq/gsx"

component Card(title gsx.Node) { <div class="card">{title}</div> }

component Page(variant int) {
	<Card title="Hi" class={ "base", switch variant {
	case 1: "primary"
	default: "secondary"
	} } />
}
