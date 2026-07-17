package views


import "github.com/gsxhq/gsx"
component div(children gsx.Node) {
	<div><span>{children}</span></div>
}

component span(children gsx.Node) {
	<span><div>{children}</div></span>
}

component Page() {
	<p>hi</p>
}
