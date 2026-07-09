package views

import "github.com/gsxhq/gsx"

component Demo(s string, n int, f float64, ok bool, node gsx.Node, price Money) {
	<div>{s}|{n}|{f}|{ok}|{node}|{price}</div>
}
