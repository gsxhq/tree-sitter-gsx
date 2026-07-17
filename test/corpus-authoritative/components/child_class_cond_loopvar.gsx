package views

import "github.com/gsxhq/gsx"

component Item(label string, attrs gsx.Attrs) {
	<span { attrs... }>{ label }</span>
}

component List(xs []string) {
	{ for i, x := range xs {
		<Item label={x} class={ "first": i == 0 } />
	} }
}
