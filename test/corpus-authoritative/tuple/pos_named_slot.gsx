package views

import "github.com/gsxhq/gsx"

func makeTitle(s string) (string, error) { return "-- " + s + " --", nil }

component Panel(header gsx.Node) {
	<div class="panel">{header}</div>
}

component Page(title string) {
	<Panel header={ <h2>{ makeTitle(title) }</h2> }/>
}
