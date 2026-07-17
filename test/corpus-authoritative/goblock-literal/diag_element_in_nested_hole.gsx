package demo

component Page() {
	{{ h := js`f(@{ <b>y</b> })` }}
	<button @click={h}>x</button>
}
