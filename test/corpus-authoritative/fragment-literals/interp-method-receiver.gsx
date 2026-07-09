package views

import "github.com/gsxhq/gsx"

component Noop() {
	<span/>
}

type Card struct {
	Title string
}

func (c Card) View() gsx.Node {
	return <><h2>{ c.Title }</h2></>
}

component Host() {
	{ Card{Title: "Hi"}.View() }
}
