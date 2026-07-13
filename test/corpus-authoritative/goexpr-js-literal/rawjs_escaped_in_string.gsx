package demo

import "github.com/gsxhq/gsx"

var h = gsx.RawJS("x') ; steal('")

var handler = js`f('@{h}')`

component Page() {
	<button @click={handler}>x</button>
}
