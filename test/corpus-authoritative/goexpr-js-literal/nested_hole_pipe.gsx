package demo

var h = js`f(@{ f`x` |> upper })`

component Page() {
	<button @click={h}>x</button>
}
