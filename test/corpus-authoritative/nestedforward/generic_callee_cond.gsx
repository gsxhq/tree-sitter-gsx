package views


import "github.com/gsxhq/gsx"
component List[T any](items []T, attrs gsx.Attrs) {
	<ul class="list" { attrs... }>
		{ for _, it := range items {
			<li>{ it |> printf("%v") }</li>
		} }
	</ul>
}

component Wrap(attrs gsx.Attrs) {
	<List items={[]string{"a"}} { if attrs.Has("hot") { data-hot="1" } }/>
}

component Page() {
	<Wrap hot="x"/>
}
