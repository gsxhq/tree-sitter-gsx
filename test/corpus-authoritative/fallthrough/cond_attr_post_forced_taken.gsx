package views


import "github.com/gsxhq/gsx"
component Box(active bool, attrs gsx.Attrs) {
	<button { attrs... } { if active { id="mine" } }>x</button>
}

component Page() {
	<Box active={true} id="caller" data-x="1"/>
}
