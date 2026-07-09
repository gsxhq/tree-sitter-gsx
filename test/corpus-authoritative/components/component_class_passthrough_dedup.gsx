package views

component Bare(title string) {
	<div { attrs... }>{title}</div>
}

component Page() {
	<Bare title="hi" class={ "dup", "dup", "keep" }/>
}
