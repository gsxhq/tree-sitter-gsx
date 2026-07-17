package views

import "github.com/gsxhq/gsx"

component Wrap(children gsx.Node) {
	<div>{children}</div>
}

component Page(before string, mid int, after bool) {
	<span>{before}</span>
	<Wrap><em>{mid}</em></Wrap>
	<span>{after}</span>
}
