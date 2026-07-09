package p

component Row(id string, n int) {
	<div data-key=f`row-@{id}-@{n}` title=f`Item @{ id |> upper }`>x</div>
}
