package views

import "github.com/gsxhq/gsx"

component InterposedPipeHole(p gsx.Attrs, u string, q gsx.Attrs) {
	<a { p... } href={ u |> trim } { q... }>x</a>
}
