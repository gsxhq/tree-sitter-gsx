package views

component Button() {
	<button { attrs... }>{children}</button>
}

component Page() {
	<Button data-test="t" hx-post="/x">Go</Button>
}
