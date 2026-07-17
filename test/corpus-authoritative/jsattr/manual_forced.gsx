package views


import "github.com/gsxhq/gsx"
component Dialog(children gsx.Node, attrs gsx.Attrs) {
	<div { attrs... } role="dialog">{children}</div>
}
