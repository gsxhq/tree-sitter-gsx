package views

component Wrap() {
	<div>{children}</div>
}

component Page(before string, mid int, after bool) {
	<span>{before}</span>
	<Wrap><em>{mid}</em></Wrap>
	<span>{after}</span>
}
