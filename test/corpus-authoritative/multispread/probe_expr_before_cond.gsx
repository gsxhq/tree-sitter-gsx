package views

import "github.com/gsxhq/gsx"

func label(v string) string { return v }

component Page(on bool, extra gsx.Attrs) {
	<div data-a={ label("a") } { if on { { extra... } } } { gsx.Attrs{{Key: "data-z", Value: "z"}}... }>x</div>
}
