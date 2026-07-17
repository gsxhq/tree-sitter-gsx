package views

import "github.com/gsxhq/gsx"

component C(mode string, attrs gsx.Attrs) {
	{ switch mode {
	case "a":
		{{ attrs := gsx.Attrs{{Key: "data-local", Value: "1"}} }}
		<span { attrs... }>a</span>
	case "b":
		<div { attrs... }>b</div>
	} }
}
