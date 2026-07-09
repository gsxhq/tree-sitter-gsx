package views

import "github.com/gsxhq/gsx"

component Box[T string | int](value T) {
	<span>{value}</span>
}

component Panel(header gsx.Node) {
	<div class="panel"><div class="hd">{header}</div></div>
}

component Page() {
	<Panel header={ <Box value={7} /> }/>
}
