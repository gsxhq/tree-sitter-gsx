package views

component Tags(csv string) {
	<p>{ csv |> parse |> rev |> first |> upper }</p>
}
