package views

component Box[T ~string | int](value T) {
	<span>{value}</span>
}

component Page() {
	<Box[string] value={"x"} />
}
