package views

import "github.com/gsxhq/gsx"

func wrap(n gsx.Node) gsx.Node { return n }

component Page() {
	<div>{ wrap(<list[int]/>) }</div>
}
