package views


import "github.com/gsxhq/gsx"
component Panel(title string, attrs gsx.Attrs) {
	<section><h2>{title}</h2><aside { attrs.Without("title")... }>body</aside></section>
}

component Page() {
	<Panel title="Hi" data-test="x" placeholder="p"/>
}
