package demo

var name = "x"

var h = js`f(@{name |> risky})`

component Page() {
	<button @click={h}>x</button>
}
