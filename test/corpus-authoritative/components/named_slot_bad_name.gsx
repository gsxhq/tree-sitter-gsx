package views

import "github.com/gsxhq/gsx"

component Panel(header gsx.Node) {
	<div>{header}</div>
}

component Page() {
	<Panel data-x={ <m/> }/>
}
