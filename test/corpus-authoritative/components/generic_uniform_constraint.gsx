package views

type Slug string

component Tag[T ~string](value T) {
	<b>{value}</b>
}

component Page() {
	<Tag[Slug] value={Slug("go")} />
}
