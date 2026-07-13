package views

import "github.com/gsxhq/gsx"

component Slot(body gsx.Node) { <section>{body}</section> }

component Page(n int) {
	<Slot body=f`<b>@{nodeCount(n)}</b>`/>
}
