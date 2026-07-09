package views

component C(v int) {
	<span style={ "padding: 4px", sty(v) }>x</span>
}

func sty(v int) (string, error) { return "color: red", nil }
