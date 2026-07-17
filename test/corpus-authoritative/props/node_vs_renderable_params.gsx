package views

import "github.com/gsxhq/gsx"

component Card(header gsx.Node, icon widget, title string) {
	<div>{header}{icon}{title}</div>
}

component Page(w widget) {
	<Card header="Hello" icon={w} title="World"/>
}
