package views

import "github.com/gsxhq/gsx"

component Card(title gsx.Node, body gsx.Node) {
	<article><h2>{title}</h2><section>{body}</section></article>
}

component Page(count int) {
	<Card title="My Card" body={count}/>
	<Card title={ <strong>Bold Title</strong> } body={ gsx.Raw("<em>raw</em>") }/>
}
