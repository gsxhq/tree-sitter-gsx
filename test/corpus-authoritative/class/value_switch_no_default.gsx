package views

component Badge(v int) {
	<span class={ "base", switch v { case 1: "one" } }>x</span>
}
