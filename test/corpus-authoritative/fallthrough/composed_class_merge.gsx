package views

component Box(variant string) {
	<div class={ "box", variant } { attrs... }>{children}</div>
}
