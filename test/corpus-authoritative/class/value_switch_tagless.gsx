package views

component C(v int) {
	<div class={ switch { case v > 0: "pos" default: "nonpos" } }>x</div>
}
