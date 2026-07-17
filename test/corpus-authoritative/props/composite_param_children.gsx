package views

import "github.com/gsxhq/gsx"

type Props struct {
	Variant string
}

component Button(p Props, children gsx.Node) {
	<button class={ "btn", p.Variant }>{ children }</button>
}

component Page() {
	<Button p={Props{Variant: "primary"}}>Save</Button>
}
