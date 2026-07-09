package views

import "github.com/gsxhq/gsx"

component Noop() {
	<span/>
}

func Panel() gsx.Node {
	return <><h1>Title</h1><p>Body</p></>
}

component Host() {
	{ Panel() }
}
