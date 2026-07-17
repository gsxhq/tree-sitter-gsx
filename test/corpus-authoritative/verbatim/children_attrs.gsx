package views

import "github.com/gsxhq/gsx"

component Panel(children gsx.Node) {
	<section>{children}</section>
}

component Tabs(children ...gsx.Node) {
	<ul>{ for _, c := range children { <li>{c}</li> } }</ul>
}

component Card(header gsx.Node, attrs gsx.Attrs) {
	<div {attrs...}>{header}</div>
}

component Page() {
	<Panel></Panel>
	<Panel><b>hi</b></Panel>
	<Tabs></Tabs>
	<Tabs><span>a</span><span>b</span></Tabs>
	<Card header={<h1>T</h1>} class="c"/>
}
