package views

component Panel() {
	<section { attrs... }>{children}</section>
}

component Page() {
	<Panel attrs={{ "a": "1" }} attrs={{ "b": "2" }}/>
}
