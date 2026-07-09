package views

func handler(action string) (string, error) { return "doThing('" + action + "')", nil }

component Button(action string) {
	<button onclick={ handler(action) }>click</button>
}
