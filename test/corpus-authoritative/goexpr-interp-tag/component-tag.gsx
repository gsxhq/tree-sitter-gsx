package demo

import "github.com/gsxhq/gsx"

func wrap(n gsx.Node) gsx.Node { return n }

component Badge(count int) {
	<span>{ count }</span>
}

component Uses(n int) {
	<div>{ wrap(<Badge count={n}/>) }</div>
}
