package views

component Tags(csv string) {
	<p>{ csv |> parse |> first }</p>
}
