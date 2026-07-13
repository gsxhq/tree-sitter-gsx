package demo

var x = "a`b"

var handler = js"save(`@{x}`)"

component Page() {
	<button @click={handler}>x</button>
}
