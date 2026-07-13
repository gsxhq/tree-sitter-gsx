package views

component list[T string | int](v T) {
	<span>{v}</span>
}

component Page() {
	<list[int] v={1}/>
}
