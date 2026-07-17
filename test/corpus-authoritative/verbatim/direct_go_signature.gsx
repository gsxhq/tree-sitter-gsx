package views

import "github.com/gsxhq/gsx"

type History struct{ Label string }

component Page(h History) {
	<p>{h.Label}</p>
}

var _ func(History) gsx.Node = Page
