package views

component Panel() {
	<section { attrs... }>{children}</section>
}

component Wrapper() {
	<Panel { attrs... }>text child</Panel>
}

component Page() {
	<Wrapper data-x="1"/>
}
