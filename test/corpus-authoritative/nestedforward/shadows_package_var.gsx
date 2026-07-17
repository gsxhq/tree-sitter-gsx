package views


import "github.com/gsxhq/gsx"
component Panel(attrs gsx.Attrs) {
	<div { attrs... }>p</div>
}

component Page() {
	<Panel data-caller="yes"/>
}
