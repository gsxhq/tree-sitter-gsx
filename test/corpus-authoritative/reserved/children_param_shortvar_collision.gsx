package views


import "github.com/gsxhq/gsx"
component Page(children gsx.Node) {
	{{ children := "hi" }}
	<div>{children}</div>
}
