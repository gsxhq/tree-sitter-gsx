package views

component Box() {
	<div { attrs... } id="x" { attrs... }>{children}</div>
}

component Page() {
	<Box id="a" data-z="1">c</Box>
}
