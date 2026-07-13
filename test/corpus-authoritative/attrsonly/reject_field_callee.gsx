package views

import "github.com/gsxhq/gsx"

type holder struct {
	Icon func(gsx.Attrs) gsx.Node
}

component Page(item holder) {
	<item.Icon class="x"/>
}
