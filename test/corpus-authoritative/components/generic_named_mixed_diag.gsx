package views

type Slug string

component Box[T Slug | int](value T) {
	<span>{value}</span>
}

component Page() {
	<Box[Slug] value={Slug("x")} />
}
