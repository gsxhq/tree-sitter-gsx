package views


import "github.com/gsxhq/gsx"
component div(deep bool, children gsx.Node) {
	if deep {
		<span>{children}</span>
	}
	<div>{children}</div>
}

component span(children gsx.Node) {
	<span><div>{children}</div></span>
}

component Page() {
	<p>hi</p>
}
