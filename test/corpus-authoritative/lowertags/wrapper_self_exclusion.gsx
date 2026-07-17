package views


import "github.com/gsxhq/gsx"
component div(children gsx.Node) {
	<div class="wrapped">{children}</div>
}

component Page() {
	<div>hi</div>
}
