package views

import "github.com/gsxhq/gsx"

component CondSpread(on bool, extra gsx.Attrs) {
	<div>
		<a { if on { { extra... } } }>on</a>
		<a { if !on { { extra... } } }>off</a>
	</div>
}
