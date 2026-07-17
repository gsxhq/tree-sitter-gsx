package views


import "github.com/gsxhq/gsx"
component Card(children gsx.Node, attrs gsx.Attrs) {
	<div class="card" style="color:red" { attrs... }>{children}</div>
}
