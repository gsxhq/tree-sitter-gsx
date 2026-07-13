package views

component Tag(name string) {
	<div>{f`hi-@{name}` |> wrapText}</div>
}
