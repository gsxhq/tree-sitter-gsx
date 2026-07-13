package views

import "github.com/gsxhq/gsx"

component Card(link string, cardAttrs gsx.Attrs) {
	<a href={link} { cardAttrs... }>click</a>
}

component Page() {
	<Card link="/safe" card-attrs={{ "HREF": "javascript:alert(1)" }}/>
}
