package views

import "github.com/gsxhq/gsx"

type LocalAttrs []gsx.Attr

func bag(id string) LocalAttrs {
	return LocalAttrs{{Key: "id", Value: id}}
}

component Panel(attrs gsx.Attrs) {
	<div { attrs... }></div>
}

component Page() {
	<Panel attrs={bag("explicit")} />
	<Panel { bag("spread")... } />
}
