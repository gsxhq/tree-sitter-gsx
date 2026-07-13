package views

component Chip() {
	<span { attrs... }>x</span>
}

component Page(on bool) {
	<div>
		<Chip class={ if on { "a" } else { "b" } }/>
		<Chip class={ if on { "a" } else { "b" } }/>
	</div>
}
