package views


import "github.com/gsxhq/gsx"
component Box(active bool, attrs gsx.Attrs) {
	<button { attrs... } { if active { id="mine" } }>x</button>
}

component Page() {
	<Box active={false} id="caller"/>
}
