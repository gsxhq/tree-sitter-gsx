package views

component Link() {
	<a { attrs... }>go</a>
}

component Wrapper() {
	<Link { attrs... }/>
}

component Page() {
	<Wrapper href="javascript:alert(1)"/>
}
