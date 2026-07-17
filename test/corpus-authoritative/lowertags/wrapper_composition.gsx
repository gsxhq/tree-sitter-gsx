package views


import "github.com/gsxhq/gsx"
component div(children gsx.Node) {
	<div class="d"><span>{children}</span></div>
}

component span(children gsx.Node) {
	<span class="s">{children}</span>
}

component Page() {
	<div>hi</div>
}
