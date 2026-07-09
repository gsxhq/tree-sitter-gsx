package views

var calls int

component C(label string) {
	<div style={ setState(), if calls == 1 { "color: green" } else { "color: red" } }>{label}</div>
}

func setState() string {
	calls++
	return "display: block"
}
