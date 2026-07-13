package views

type CardProps struct {
	Title string
}

component Card(p CardProps) {
	<div>{p.Title}</div>
}

component Wrapper() {
	<Card { attrs... }/>
}

component Page() {
	<Wrapper data-x="1"/>
}
