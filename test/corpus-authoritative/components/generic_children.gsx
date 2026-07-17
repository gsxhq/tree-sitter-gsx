package views

import "github.com/gsxhq/gsx"

component Wrap[T string | int](title T, children gsx.Node) {
	<div>{title}{children}</div>
}

component Page() {
	<Wrap[string] title={"hi"}><em>kid</em></Wrap>
}
