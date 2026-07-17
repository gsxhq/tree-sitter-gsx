package views

import "github.com/gsxhq/gsx"

type CardProps struct {
	Title string
}

component Card(p CardProps) {
	<div>{p.Title}</div>
}

component Wrapper(attrs gsx.Attrs) {
	<Card p={CardProps{Title: "card"}} { attrs... }/>
}

component Page() {
	<Wrapper data-x="1"/>
}
