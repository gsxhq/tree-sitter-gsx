package views

import "github.com/gsxhq/gsx"

type ctrlProps struct {
	Attrs gsx.Attrs
}

component Ctrl(p ctrlProps) {
	<button { p.Attrs... }>go</button>
}

component Page() {
	<Ctrl p={ctrlProps{Attrs: gsx.Attrs{{Key: "hx-get", Value: "/path"}, {Key: "data-role", Value: "tab"}}}}/>
}
