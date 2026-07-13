package views

import "github.com/gsxhq/gsx"

component InterposedBoolScalar(p gsx.Attrs, q gsx.Attrs) {
	<button { p... } disabled data-n={5} { q... }>go</button>
}
