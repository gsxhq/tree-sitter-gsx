package views

component Box[T string | int](value T) {
	<span>{value}</span>
}

component Page() {
	<Box[int] value={7} />
	<Box[string] value={"ok"} />
}
