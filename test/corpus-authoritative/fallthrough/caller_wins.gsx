package views


import "github.com/gsxhq/gsx"
component Link(children gsx.Node, attrs gsx.Attrs) {
	<a href="/x" { attrs... }>{children}</a>
}
