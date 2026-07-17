package views


import "github.com/gsxhq/gsx"
component Bare(title string, attrs gsx.Attrs) {
	<div { attrs... }>{title}</div>
}

component Page() {
	<Bare title="hi" class={ "dup", "dup", "keep" }/>
}
