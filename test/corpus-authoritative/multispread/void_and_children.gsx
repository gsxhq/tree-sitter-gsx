package views

import "github.com/gsxhq/gsx"

component VoidAndChildren(a gsx.Attrs, b gsx.Attrs) {
	<div>
		<input { a... } { b... }/>
		<span { a... } { b... }>hi</span>
	</div>
}
