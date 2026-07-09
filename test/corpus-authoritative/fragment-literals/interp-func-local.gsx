package views

import "github.com/gsxhq/gsx"

component Noop() {
	<span/>
}

func Greeting(name string) gsx.Node {
	return <><span>Hello </span><span>{ name }</span></>
}

component Host() {
	{ Greeting("world") }
}
