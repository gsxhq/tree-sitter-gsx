package views

component Tag(name string) {
	<div title={f`hi-@{name}` |> wrapText}>ok</div>
}
