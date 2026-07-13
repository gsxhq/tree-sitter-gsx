package views

component Greeting[V ~string, W any](v V, w W) {
	<p>{ v }</p>
	<p>{ w |> printf("%v") }</p>
}

type MyByte byte

component ByteBox[T []MyByte | string](value T) {
	<p>{ string(value) }</p>
}

component Page() {
	<Greeting v="hello" w="world" />
	<ByteBox value={[]MyByte{'x'}} />
}
