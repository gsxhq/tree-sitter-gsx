package views

component Field[T string | int](value T) {
	<input value={value} />
}

component Page() {
	<Field[int] value={7} />
	<Field[string] value={"a<b"} />
}
