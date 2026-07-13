package views

import "github.com/gsxhq/gsx"

var calls []string

func bag(mark string) gsx.Attrs {
	calls = append(calls, mark)
	return gsx.Attrs{{Key: "data-k", Value: mark}}
}

component Page() {
	<div { bag("prior")... } title=f"value @{failHole()}" { bag("late")... }>x</div>
}
