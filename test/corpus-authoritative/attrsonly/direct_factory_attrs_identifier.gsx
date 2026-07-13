package views

import "github.com/gsxhq/gsx"

func label(attrs string) gsx.Node {
	return <span>{ attrs }</span>
}

component Page() {
	{ label("plain text") }
}
