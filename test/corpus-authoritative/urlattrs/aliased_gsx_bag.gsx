package views

import g "github.com/gsxhq/gsx"

component C(extra g.Attrs) {
	<a { extra... }>x</a>
}

component Page() {
	<C extra={g.Attrs{{Key: "href", Value: "javascript:alert(1)"}}}/>
}
