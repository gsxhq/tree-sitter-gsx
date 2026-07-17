package views


import "github.com/gsxhq/gsx"
component Kids(children gsx.Node) {
	{{ hasKids := children != nil }}
	<section data-has-kids={hasKids}>{children}</section>
}

component Page() {
	<Kids>hi</Kids>
}
