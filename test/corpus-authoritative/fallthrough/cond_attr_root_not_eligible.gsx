package views

component Box(active bool) {
	<button { if active { id="real" } }>x</button>
}

component Page() {
	<Box active={true} id="caller"/>
}
