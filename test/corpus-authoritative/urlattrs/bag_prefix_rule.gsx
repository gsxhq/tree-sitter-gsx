package views

import "github.com/gsxhq/gsx"

type navProps struct {
	Attrs gsx.Attrs
}

component Nav(p navProps) {
	<div { p.Attrs... }>x</div>
}

component Page() {
	<Nav data-url-next={"javascript:alert(1)"} data-x={"keep"}/>
}
