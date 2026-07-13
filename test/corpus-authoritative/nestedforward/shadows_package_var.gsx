package views

component Panel() {
	<div { attrs... }>p</div>
}

component Page() {
	<Panel data-caller="yes"/>
}
