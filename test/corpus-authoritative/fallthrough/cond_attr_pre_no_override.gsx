package views


import "github.com/gsxhq/gsx"
component Box(active bool, attrs gsx.Attrs) {
	<button { if active { id="mine" data-k="v" } } { attrs... }>x</button>
}

component Page() {
	<Box active={true}/>
}
