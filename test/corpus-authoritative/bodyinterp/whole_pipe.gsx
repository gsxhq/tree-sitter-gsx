package p

component Item(id string) {
	<p>{f`item-@{id}` |> upper}</p>
}
