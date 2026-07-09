package views

type State struct {
	Tab  string
	Open bool
}

component Page(state State) {
	<div x-data={ state }>x</div>
}
