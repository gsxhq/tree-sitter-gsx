package demo

var h = js`f(@{ <b>y</b> })`

component Page() {
	<button @click={h}>x</button>
}
