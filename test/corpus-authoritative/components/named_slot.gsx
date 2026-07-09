package views

import "github.com/gsxhq/gsx"

component Panel(header gsx.Node) {
	<div class="panel"><div class="hd">{header}</div></div>
}

component Page() {
	<Panel header={ <h1>Title</h1> }/>
}
