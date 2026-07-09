package views

component C() {
	{{ a := false }}
	{{ b := true }}
	<span class={ if a { "one" } else if b { "two" } }>x</span>
}
