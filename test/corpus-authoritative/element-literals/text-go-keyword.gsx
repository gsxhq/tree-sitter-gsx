package demo

import "github.com/gsxhq/gsx"

var X = (
	<div>
		<h1>Test</h1>
		<p>This is a test component.</p>
	</div>
)

func local() gsx.Node {
	n := <em>another component</em>
	return n
}

component Uses() {
	<section>{ X }{ local() }</section>
}
