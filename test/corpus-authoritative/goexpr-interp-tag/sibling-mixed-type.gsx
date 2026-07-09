package demo

import "github.com/gsxhq/gsx"

func wrap(n gsx.Node) gsx.Node { return n }

component Uses(name string, other int) {
	<div>{ wrap(<b>{ name }</b>) }{ other }</div>
}
