package views

component Button(variant string) {
	<button data-variant={variant} { attrs... }>{children}</button>
}

component Page() {
	<Button variant="primary" role="button">Go</Button>
}
