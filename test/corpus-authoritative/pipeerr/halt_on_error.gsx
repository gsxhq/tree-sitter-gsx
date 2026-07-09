package views

component Hi(name string) {
	<p>{ name |> fail |> detonate }</p>
}
