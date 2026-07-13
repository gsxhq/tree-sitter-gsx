package views

import (
	"corpustest/cases/goexpr-js-literal_renderer_hole/pg"
	"github.com/gsxhq/gsx"
)

func mkJSVal(s string, valid bool) pg.JSVal   { return pg.JSVal{String: s, Valid: valid} }
func mkCSSVal(s string, valid bool) pg.CSSVal { return pg.CSSVal{String: s, Valid: valid} }

func mkClick(val pg.JSVal) gsx.RawJS {
	return js`save('@{ val }')`
}

func mkColor(val pg.CSSVal) gsx.RawCSS {
	return css`color:@{ val }`
}

component Tag(j pg.JSVal, c pg.CSSVal) {
	<button @click={mkClick(j)}>x</button>
	<div style={mkColor(c)}>y</div>
}
