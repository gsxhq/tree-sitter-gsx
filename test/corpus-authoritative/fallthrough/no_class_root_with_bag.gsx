package views


import "github.com/gsxhq/gsx"
component P(children gsx.Node, attrs gsx.Attrs) {
	<p { attrs... }>{children}</p>
}
