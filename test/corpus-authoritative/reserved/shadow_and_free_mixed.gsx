package views

import "github.com/gsxhq/gsx"

func bags() []gsx.Attrs {
	return []gsx.Attrs{
		{{Key: "class", Value: "a"}},
		{{Key: "class", Value: "b"}},
	}
}

component Mixed(attrs gsx.Attrs) {
	<div { attrs... }>{ for _, attrs := range bags() { <span { attrs... }>i</span> } }</div>
}
