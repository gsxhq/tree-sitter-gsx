package demo

import . "github.com/gsxhq/gsx"

func wrap(n Node) Node { return n }

component Uses() {
	<div>{ wrap(<b>hi</b>) }</div>
}
