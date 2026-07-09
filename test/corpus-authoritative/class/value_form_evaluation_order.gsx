package views

var state bool

component C() {
	<div><span class={ setState(), if state { "on" } else { "off" } }>x</span></div>
}

func setState() string {
	state = true
	return "base"
}
