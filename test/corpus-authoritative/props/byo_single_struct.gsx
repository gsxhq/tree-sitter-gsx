package views

import "github.com/gsxhq/gsx"

type Props struct {
	Variant  string
	Children gsx.Node
}

component Button(p Props) {
	<button class={ "btn", p.Variant }>{ p.Children }</button>
}

component Page() {
	<Button variant="primary">Save</Button>
}
