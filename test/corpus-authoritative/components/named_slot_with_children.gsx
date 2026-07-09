package views

import "github.com/gsxhq/gsx"

component Panel(header gsx.Node) {
	<section>{header}{children}</section>
}

component Page() {
	<Panel header={ <h1>T</h1> }><p>body</p></Panel>
}
