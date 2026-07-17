package views


import "github.com/gsxhq/gsx"
component Box(variant string, children gsx.Node, attrs gsx.Attrs) {
	<div class={ "box", variant } { attrs... }>{children}</div>
}
