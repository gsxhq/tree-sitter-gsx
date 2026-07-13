package demo

var x = "y"

var h = js`f('@{x}`

component Page() {
	<button @click={h}>x</button>
}
