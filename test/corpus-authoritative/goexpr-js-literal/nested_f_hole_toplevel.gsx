package demo

var h = js`f(@{ f`x` })`

component Page() {
	<button @click={h}>x</button>
}
