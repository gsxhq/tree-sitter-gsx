package views


import "github.com/gsxhq/gsx"
func makeText(tag string) (string, error) { return "[" + tag + "]", nil }

component Wrap(children gsx.Node) {
	<div>{children}</div>
}

component Page(t string) {
	<Wrap>{ makeText(t) }</Wrap>
}
