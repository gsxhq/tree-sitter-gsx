package views

import "github.com/gsxhq/gsx"

component Box(flag gsx.Node) {
	<div>{flag}</div>
}

component Page() {
	<Box flag/>
}
