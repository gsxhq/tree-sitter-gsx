package p

component Panel() {
	<section { attrs... }>{children}</section>
}

component Home() {
	<Panel attrs={{ "data-a": "1" }}>x</Panel>
	<Panel Attrs={{ "data-a": "1" }}>x</Panel>
}
