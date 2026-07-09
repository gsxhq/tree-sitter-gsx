package views

component C() {
	{{ disabled := true }}
	<button class={ "btn", if disabled { "disabled" } }>x</button>
}
