package views

import "github.com/gsxhq/gsx"

component Card(title string, attrs gsx.Attrs) { <div class="card" {attrs...}>{title}</div> }

component Page(v int, flag bool) {
	<Card title="Hi" class={ "base", if flag { cls(v) } else { "gray" } } />
}

func cls(v int) (string, error) { return "green", nil }
