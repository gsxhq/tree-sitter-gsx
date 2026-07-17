package views


import "github.com/gsxhq/gsx"
component Plain(title string) {
	<h1>{title}</h1>
}

component Wrapper(attrs gsx.Attrs) {
	<Plain { attrs... }/>
}

component Page() {
	<Wrapper data-x="1"/>
}
