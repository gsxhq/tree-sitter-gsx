package views

component Wrap[T string | int](title T) {
	<div>{title}{children}</div>
}

component Page() {
	<Wrap[string] title={"hi"}><em>kid</em></Wrap>
}
