package views

import "github.com/gsxhq/gsx"

type Props struct {
	FullWidth bool
	AriaLabel string
	Attrs     gsx.Attrs
}

component Button(p Props) {
	<div>{ p.AriaLabel }</div>
}

component Page() {
	<Button full-width aria-label="Close" data-id="7"/>
}
