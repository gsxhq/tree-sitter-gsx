package views


import "github.com/gsxhq/gsx"
component Box(children gsx.Node, attrs gsx.Attrs) {
	<div id="x" { attrs... }>{children}</div>
}
