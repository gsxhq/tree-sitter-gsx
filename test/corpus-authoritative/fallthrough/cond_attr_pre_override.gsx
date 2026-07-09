package views

component Box(active bool) {
	<button { if active { id="mine" data-k="v" } } { attrs... }>x</button>
}

component Page() {
	<Box active={true} id="caller"/>
}
