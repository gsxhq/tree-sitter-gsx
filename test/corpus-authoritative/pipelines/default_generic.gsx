package views

component Summary(count int, enabled bool, title string) {
	<p>{ count |> default(12) }|{ enabled |> default(true) }|{ title |> default("Untitled") }</p>
}
