package views

import "github.com/gsxhq/gsx"

component O1(on bool, extra gsx.Attrs) {
	<div class="root" { if on { { extra... } } }>x</div>
}
