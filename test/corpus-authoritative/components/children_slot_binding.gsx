package views

import "github.com/gsxhq/gsx"

component Wrap(children gsx.Node) {
	<div>{children}</div>
}

component Page(name string, items []string) {
	<Wrap>
		<span>{name}</span>
		{ for _, it := range items { <li>{it}</li> } }
	</Wrap>
}
