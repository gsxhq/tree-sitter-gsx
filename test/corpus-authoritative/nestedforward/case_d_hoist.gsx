package views

import "github.com/gsxhq/gsx"

func getAttrs() gsx.Attrs {
	return gsx.Attrs{{Key: "data-g", Value: "g"}}
}

func compute() string {
	return "c"
}

component Panel() {
	<div { attrs... }>p</div>
}

component Page() {
	<Panel { getAttrs()... } data-x={ compute() }/>
}
