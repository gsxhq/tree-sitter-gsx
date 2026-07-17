package demo

var name = "x"

var h = js`f(@{ f`@{name |> risky}` })`

component Page() {
	<button @click={h}>x</button>
}
