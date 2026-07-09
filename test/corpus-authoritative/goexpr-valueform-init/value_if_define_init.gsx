package views

component Label() {
	<span class={ "base", if x := ready(); x { "on" } }>y</span>
}

func ready() bool { return true }
