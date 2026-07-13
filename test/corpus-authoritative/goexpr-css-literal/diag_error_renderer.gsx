package demo

import "corpustest/cases/goexpr-css-literal_diag_error_renderer/pg"

var val = pg.Text{String: "red"}

var h = css`color:@{val}`

component Page() {
	<div style={h}>x</div>
}
