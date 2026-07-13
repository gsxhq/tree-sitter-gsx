package views

import "github.com/gsxhq/gsx"

func Icon(attrs ...gsx.Attr) gsx.Node {
	return (
		<svg { attrs... }>x</svg>
	)
}

component Page() {
	<div>{ Icon(gsx.Attr{Key: "class", Value: "ic"}) }</div>
}
