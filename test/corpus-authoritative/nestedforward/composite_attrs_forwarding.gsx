package views

import "github.com/gsxhq/gsx"

type CardProps struct {
	Title string
}

component Card(p CardProps, attrs gsx.Attrs) {
	<div { attrs... }>{p.Title}</div>
}

component Wrapper(attrs gsx.Attrs) {
	<Card p={CardProps{Title: "card"}} { attrs... }/>
}

component Page() {
	<Wrapper data-x="1"/>
}
