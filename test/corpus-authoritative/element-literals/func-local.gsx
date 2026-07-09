package demo

import "github.com/gsxhq/gsx"

component Noop() {
	<span/>
}

func Greeting(name string) gsx.Node {
	greeting := "Hi, " + name
	return <div>{ greeting } ({ name })</div>
}
