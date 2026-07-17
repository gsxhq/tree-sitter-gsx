package views

import "github.com/gsxhq/gsx"

component C(cond bool, attrs gsx.Attrs) {
	{ if cond {
		{{ attrs := gsx.Attrs{{Key: "data-local", Value: "1"}} }}
		<span { attrs... }>t</span>
	} else {
		<div { attrs... }>e</div>
	} }
}
