package views

import "github.com/gsxhq/gsx"

type CardProps struct {
	Title string
	Attrs gsx.Attrs
}

component Card(p CardProps) {
	<div { p.Attrs... }>{p.Title}</div>
}

component Wrapper() {
	<Card { attrs... }/>
}

component Page() {
	<Wrapper data-x="1"/>
}
