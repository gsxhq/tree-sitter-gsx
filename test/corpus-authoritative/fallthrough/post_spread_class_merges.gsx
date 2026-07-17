package views


import "github.com/gsxhq/gsx"
component Box(attrs gsx.Attrs) {
	<div { attrs... } class="forced">y</div>
}

component Page() {
	<Box class="w-full"/>
}
