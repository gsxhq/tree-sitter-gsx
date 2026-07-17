package views


import "github.com/gsxhq/gsx"
component card(children gsx.Node) {
	<div class="card">{children}</div>
}

component Page() {
	<card>hi</card>
	<span>bye</span>
}
