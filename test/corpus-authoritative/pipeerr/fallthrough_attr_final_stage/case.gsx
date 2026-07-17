package views


import "github.com/gsxhq/gsx"
component Child(variant string, children gsx.Node, attrs gsx.Attrs) {
	<a class={ "a", variant } { attrs... }>{children}</a>
}

component Page(target string) {
	<Child variant="x" hx-get={ target |> url }>Go</Child>
}
