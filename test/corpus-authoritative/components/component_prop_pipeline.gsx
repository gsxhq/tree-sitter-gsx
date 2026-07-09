package views

import "github.com/gsxhq/gsx"

component Card(title gsx.Node) { <div class="card">{title}</div> }

component Page(name string) {
	<Card title={ name |> upper } />
}
