package views

func greet(name string) (string, error) { return "Hello " + name, nil }

component Label(name string) {
	<span>{ greet(name) }</span>
}
