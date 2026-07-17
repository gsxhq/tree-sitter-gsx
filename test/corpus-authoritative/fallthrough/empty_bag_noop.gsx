package views


import "github.com/gsxhq/gsx"
component Box(variant string, children gsx.Node) {
	<div class={ "box", variant }>{children}</div>
}
