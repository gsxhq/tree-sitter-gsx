package views

component Field(label string) { <input aria-label={label} { attrs... }/> }

component Wrap[T string | int](edit bool, v T) {
	<Field label="c" { if edit { title=f"Hi @{v}" } } />
}

component Page() {
	<Wrap[string] edit={true} v={"a<b"} />
	<Wrap[int] edit={true} v={7} />
}
