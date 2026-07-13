package views

component List[T any](items []T) {
	<ul class="list" { attrs... }>
		{ for _, it := range items {
			<li>{ it |> printf("%v") }</li>
		} }
	</ul>
}

component Wrap() {
	<List items={[]string{"a", "b"}} { attrs... }/>
}

component Page() {
	<Wrap data-flag="1" class="hot"/>
}
