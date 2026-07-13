package views

import "corpustest/cases/renderers_numeric_result/pg"

func mkCount(n int, valid bool) pg.Count { return pg.Count{N: n, Valid: valid} }

component Tag(val pg.Count) {
	<div data-n={ val }>{ val }</div>
}
