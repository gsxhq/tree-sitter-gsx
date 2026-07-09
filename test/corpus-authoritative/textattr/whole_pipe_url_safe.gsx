package p

component Link(u string) {
	<a href={f`@{u}` |> upper}>go</a>
}
