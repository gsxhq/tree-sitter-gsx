package views

import "github.com/gsxhq/gsx"

component Panel(lead gsx.Node) {
	<div>{lead}{children}</div>
}

component Page(s string, n int, b bool, f float64) {
	<span>{s}</span>
	<Panel lead={ <em>{n}</em> }>{b}</Panel>
	<span>{f}</span>
}
