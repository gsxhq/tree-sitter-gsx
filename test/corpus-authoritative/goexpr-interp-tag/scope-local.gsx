package demo

import "github.com/gsxhq/gsx"

func wrap(n gsx.Node) gsx.Node { return n }

component Uses(name string) {
	<div>{ wrap(<b>{ name }</b>) }</div>
}
