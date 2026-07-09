package demo

import g "github.com/gsxhq/gsx"

func wrap(n g.Node) g.Node { return n }

component Uses() {
	<div>{ wrap(<b>hi</b>) }</div>
}
