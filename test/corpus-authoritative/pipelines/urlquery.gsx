package views

component C(q string) {
	<a href=f`/search?q=@{ q |> urlquery }`>go</a>
	<p>{ q |> urlquery }</p>
	<span title={ q |> urlquery }>x</span>
}
