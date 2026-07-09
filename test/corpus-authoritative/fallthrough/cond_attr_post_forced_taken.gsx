package views

component Box(active bool) {
	<button { attrs... } { if active { id="mine" } }>x</button>
}

component Page() {
	<Box active={true} id="caller" data-x="1"/>
}
