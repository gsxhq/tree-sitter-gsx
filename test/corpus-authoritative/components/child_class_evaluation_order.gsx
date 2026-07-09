package views

var state bool

component Card() { <div>{children}</div> }

component Page() {
	<Card class={ setState(), if state { "on" } else { "off" } }>x</Card>
}

func setState() string {
	state = true
	return "base"
}
