package p

component Row(id string, n int) {
	<p>{f`row-@{id}-@{n}`}</p>
}
