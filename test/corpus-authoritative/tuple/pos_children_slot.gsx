package views

func makeText(tag string) (string, error) { return "[" + tag + "]", nil }

component Wrap() {
	<div>{children}</div>
}

component Page(t string) {
	<Wrap>{ makeText(t) }</Wrap>
}
