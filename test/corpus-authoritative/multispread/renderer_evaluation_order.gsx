package views

import (
	"corpustest/cases/multispread_renderer_evaluation_order/pg"
	"github.com/gsxhq/gsx"
)

var calls []string

func bag(mark string) gsx.Attrs {
	calls = append(calls, mark)
	return gsx.Attrs{{Key: "data-k", Value: mark}}
}

component ExprPage(val pg.Text) {
	<div { bag("expr-prior")... } data-x={ val } { bag("expr-late")... }>x</div>
}

component ClassPage(val pg.Text) {
	<div { bag("class-prior")... } class={ val } { bag("class-late")... }>x</div>
}
