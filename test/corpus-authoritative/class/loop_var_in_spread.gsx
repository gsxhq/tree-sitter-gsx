package views

import "github.com/gsxhq/gsx"

component Rows(bags []gsx.Attrs) {
	<div>
		{ for _, a := range bags {
			<span { a... }>x</span>
		} }
	</div>
}
