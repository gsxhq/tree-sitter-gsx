package views


import "github.com/gsxhq/gsx"
component Box(children gsx.Node, attrs gsx.Attrs) {
	<div { attrs... } id="x" { attrs... }>{children}</div>
}

component Page() {
	<Box id="a" data-z="1">c</Box>
}
