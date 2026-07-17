package views

import "github.com/gsxhq/gsx"

component Card(title string, attrs gsx.Attrs) { <div class="card" {attrs...}>{title}</div> }

component Page(v int) {
	<Card title="Hi" class={ "base", cls(v) } />
}

func cls(v int) (string, error) { return "green", nil }
