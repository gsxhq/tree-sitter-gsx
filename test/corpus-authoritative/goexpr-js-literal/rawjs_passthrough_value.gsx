package demo

import "github.com/gsxhq/gsx"

var h = gsx.RawJS("inner()")

var handler = js`wrap(@{h})`

component Page() {
	<button @click={handler}>x</button>
}
