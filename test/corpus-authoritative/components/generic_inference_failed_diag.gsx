package views

component Marker[T any]() {
	<p>marker</p>
}

component Holder[T any](value any) {
	<p>{ value |> format("%v") }</p>
}

component Pair[K any, V any]() {
	<p>pair</p>
}

component Page() {
	<Marker />
	<Holder value="x" />
	<Pair />
}
