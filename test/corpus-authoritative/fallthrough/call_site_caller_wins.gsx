package views

component Button() {
	<button type="button" { attrs... }>{children}</button>
}

component Page() {
	<Button type="reset">Go</Button>
}
