package views

component List[T any](items []T) {
	<ul class="list" { attrs... }>
		{ for _, it := range items {
			<li>{ it |> printf("%v") }</li>
		} }
	</ul>
}

component Wrap() {
	<List items={[]string{"a"}} { if attrs.Has("hot") { data-hot="1" } }/>
}

component Page() {
	<Wrap hot="x"/>
}
