package demo

import "github.com/gsxhq/gsx"

var name = "world"

var vs = []gsx.RawJS{js`first()`, js`second(@{name})`}

component Uses() {
	<p>{ gsx.Text(string(vs[1])) }</p>
}
