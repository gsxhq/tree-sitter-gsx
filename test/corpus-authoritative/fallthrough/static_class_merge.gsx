package views


import "github.com/gsxhq/gsx"
component Card(children gsx.Node, attrs gsx.Attrs) {
	<section class="card" { attrs... }>{children}</section>
}
