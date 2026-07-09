package views

type MyByte byte

component Box[T []MyByte | string](value T) {
	<span>{value}</span>
}

component Page() {
	<Box[[]MyByte] value={[]MyByte{'x'}} />
}
