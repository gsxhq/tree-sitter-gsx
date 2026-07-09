package views

component Child(variant string) {
	<a class={ "a", variant } { attrs... }>{children}</a>
}

component Page(target string) {
	<Child variant="x" hx-get={ target |> url }>Go</Child>
}
