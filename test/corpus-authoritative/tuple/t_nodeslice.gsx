package views

import "github.com/gsxhq/gsx"

func makeItems(n int) ([]gsx.Node, error) {
	return []gsx.Node{gsx.Text("item")}, nil
}

component List(items []gsx.Node) {
	<ul>{items}</ul>
}

component Page(n int) { <List items={makeItems(n)}/> }
