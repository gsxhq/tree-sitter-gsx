package views

import "github.com/gsxhq/gsx"

component InterposedURL(p gsx.Attrs, qHit gsx.Attrs, qSafe gsx.Attrs) {
	<div>
		<a { p... } href="/mid" { qHit... }>hit</a>
		<a { p... } href="/mid" { qSafe... }>safe</a>
	</div>
}
