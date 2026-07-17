package views


import "github.com/gsxhq/gsx"
var state bool

component Card(children gsx.Node, attrs gsx.Attrs) { <div {attrs...}>{children}</div> }

component Page() {
	<Card class={ setState(), if state { "on" } else { "off" } }>x</Card>
}

func setState() string {
	state = true
	return "base"
}
