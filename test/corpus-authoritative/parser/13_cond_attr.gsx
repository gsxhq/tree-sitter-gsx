package examples

component Button(id string) {
	<button { if id != "" { id={id} } } { attrs... }>x</button>
}
