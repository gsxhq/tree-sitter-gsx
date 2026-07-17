package views

import "github.com/gsxhq/gsx"

component Line(label string) {
	<i>{label}</i>
}

func Free(label string) gsx.Node { return Line(label) }

type rowFunc = func(label string) gsx.Node

var freeVar = func(label string) gsx.Node { return Line(label) }

var aliasVar rowFunc = func(label string) gsx.Node { return Line(label) }

type Store struct{ prefix string }

func (s Store) Row(label string) gsx.Node { return Line(label) }

component Page(store Store) {
	<Free label="free"/>
	<freeVar label="var"/>
	<aliasVar label="alias"/>
	<store.Row label="bound"/>
}
