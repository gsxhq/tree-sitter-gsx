package views


import "github.com/gsxhq/gsx"
component Icon(attrs gsx.Attrs) {
	<span { attrs... }>i</span>
}

component Wrapper(attrs gsx.Attrs) {
	<Icon class={ attrs.Class() }/>
}

component Page() {
	<Wrapper class="w-5"/>
}
