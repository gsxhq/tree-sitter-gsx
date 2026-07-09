package views

import "github.com/gsxhq/gsx"

func wrap(n gsx.Node) gsx.Node { return n }

component Uses() {
	<div>{ wrap(<b>hi</b>) |> toHTML }</div>
}
