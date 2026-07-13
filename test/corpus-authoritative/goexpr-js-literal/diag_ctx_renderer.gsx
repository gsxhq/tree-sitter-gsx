package demo

import "corpustest/cases/goexpr-js-literal_diag_ctx_renderer/pg"

var val = pg.Text{String: "x"}

var h = js`f(@{val})`

component Page() {
	<button @click={h}>x</button>
}
