package views

component Kids() {
	{{ hasKids := children != nil }}
	<section data-has-kids={hasKids}>{children}</section>
}

component Page() {
	<Kids>hi</Kids>
}
