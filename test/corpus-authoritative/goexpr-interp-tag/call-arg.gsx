package demo

import "github.com/gsxhq/gsx"

func wrap(n gsx.Node) gsx.Node { return n }

component Uses() {
	<div>{ wrap(<><b>hi</b></>) }</div>
}
