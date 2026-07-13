package views

import "github.com/gsxhq/gsx"

func bags() []gsx.Attrs {
	return []gsx.Attrs{
		{{Key: "class", Value: "a"}},
		{{Key: "class", Value: "b"}},
	}
}

component List(label string) {
	<p>{label}</p>
	{ for _, attrs := range bags() { <span { attrs... }>i</span> } }
}
