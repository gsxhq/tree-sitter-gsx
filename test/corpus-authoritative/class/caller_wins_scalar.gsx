package views


import "github.com/gsxhq/gsx"
component Link(children gsx.Node, attrs gsx.Attrs) {
	<a href="/default" onclick="track()" { attrs... }>{children}</a>
}
