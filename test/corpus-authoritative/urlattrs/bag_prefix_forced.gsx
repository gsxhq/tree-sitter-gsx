package views

import "github.com/gsxhq/gsx"

type navProps struct {
	Attrs gsx.Attrs
}

component Nav(p navProps) {
	<a { p.Attrs... } data-url-go="/forced">x</a>
}

component Page() {
	<Nav data-url-go={"javascript:alert(1)"} data-url-keep={"/safe"}/>
}
