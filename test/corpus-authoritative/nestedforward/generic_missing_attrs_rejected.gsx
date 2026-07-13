package views

component Bare[T any](items []T) {
	<ul>
		{ for _, it := range items {
			<li>{ it |> printf("%v") }</li>
		} }
	</ul>
}

component Wrap() {
	<Bare items={[]string{"a"}} data-x="1" { attrs... }/>
}

component Page() {
	<Wrap/>
}
