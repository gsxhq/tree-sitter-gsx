package views


import "github.com/gsxhq/gsx"
component Link(u string, children gsx.Node) {
	<a href={ u }>{children}</a>
}
