package views

component Plain(title string) {
	<h1>{title}</h1>
}

component Wrapper() {
	<Plain { attrs... }/>
}

component Page() {
	<Wrapper data-x="1"/>
}
