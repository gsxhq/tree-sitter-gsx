package demo

import "corpustest/cases/goexpr-f-literal_diag_ctx_renderer_toplevel/pg"

func mk(val pg.Text) string { return f`Hi @{val}` }

component Page() {
	<div>{ mk(pg.Text{String: "x"}) }</div>
}
