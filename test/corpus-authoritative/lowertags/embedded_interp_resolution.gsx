package views

import "github.com/gsxhq/gsx"

func wrap(n gsx.Node) gsx.Node { return n }

component card() {
	<em class="card">c</em>
}

component Page() {
	<div>{ wrap(<card/>) }</div>
}
