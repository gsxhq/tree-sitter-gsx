package views


import "github.com/gsxhq/gsx"
component Child(attrs gsx.Attrs) {
	<div { attrs... }>child</div>
}

component Wrapper(attrs gsx.Attrs) {
	<Child class={attrs.Class()}/>
}
