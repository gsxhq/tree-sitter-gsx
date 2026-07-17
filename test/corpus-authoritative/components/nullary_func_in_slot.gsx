package views

import "github.com/gsxhq/gsx"

component Card(header gsx.Node, children gsx.Node) { <section>{header}{children}</section> }

component Page() {
	<Card header={ <Divider/> }><Divider/></Card>
}
