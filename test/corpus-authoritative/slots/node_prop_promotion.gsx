package views

import "github.com/gsxhq/gsx"

component Card(title gsx.Node, content gsx.Node) {
	<div class="card"><h2>{title}</h2><div class="body">{content}</div></div>
}

component Page(n int) {
	<Card title="Card Title" content={n}/>
}
