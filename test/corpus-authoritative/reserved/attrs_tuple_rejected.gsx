package views

import "github.com/gsxhq/gsx"

func lookup() (gsx.Attrs, bool) { return nil, false }

component Page() {
	{{ attrs, ok := lookup() }}
	<div { attrs... } data-ok={ok}>hi</div>
}
