package views

component Path[T string | int](v T) {
	<a href=f"/items/@{v}">x</a>
}

component Whole[T string | int](v T) {
	<a href=f"@{v}">x</a>
}

component Page() {
	<Path[string] v={"a b"} />
	<Path[int] v={7} />
	<Whole[string] v={"javascript:alert(1)"} />
}
