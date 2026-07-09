package views

component Link(csv string) {
	<a href={ csv |> parse |> pick(0) |> lower }>x</a>
}
