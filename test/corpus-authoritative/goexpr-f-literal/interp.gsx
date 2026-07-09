package demo

component Shout(label string) {
	<p>{ emphasize(f`@{label}!`) }</p>
}
