package views

import "github.com/gsxhq/gsx"

type ctrlProps struct {
	Attrs gsx.Attrs
}

component Ctrl(p ctrlProps) {
	<button { p.Attrs... }>go</button>
}

component Page() {
	<Ctrl hx-get={"/path"} data-role={"tab"}/>
}
