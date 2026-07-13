package views

import "github.com/gsxhq/gsx"

component JSCssHoleLoneSpread(c bool, u string, x gsx.Attrs) {
	<button onclick=js"do(@{u})" { if c { { x... } } }>go</button>
}
