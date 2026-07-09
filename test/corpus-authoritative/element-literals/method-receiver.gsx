package demo

import "github.com/gsxhq/gsx"

component Noop() {
	<span/>
}

type Person struct {
	Name string
}

func (p Person) Greeting() gsx.Node {
	return <div>Hello, { p.Name }!</div>
}
