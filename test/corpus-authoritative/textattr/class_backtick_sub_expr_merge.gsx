package views


import "github.com/gsxhq/gsx"
component Box(variant string, attrs gsx.Attrs) {
	<div class={`box-` + variant} { attrs... }>x</div>
}
