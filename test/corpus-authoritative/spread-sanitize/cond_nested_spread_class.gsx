package views

import "github.com/gsxhq/gsx"

component CondSpread(on bool, extra gsx.Attrs) {
	<a { if on { { extra... } } }>x</a>
}
