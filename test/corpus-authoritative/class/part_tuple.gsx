package views

component C(v int) {
	<span class={ "base", cls(v) }>x</span>
}

func cls(v int) (string, error) { return "green", nil }
