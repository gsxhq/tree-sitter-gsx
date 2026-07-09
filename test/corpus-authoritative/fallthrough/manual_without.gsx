package views

component Panel(title string) {
	<section><h2>{title}</h2><aside { attrs.Without("title")... }>body</aside></section>
}

component Page() {
	<Panel title="Hi" data-test="x" placeholder="p"/>
}
