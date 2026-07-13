package demo

component Page(v string) {
	{{ j := js`f(@{v |> up})` }}
	<button @click={j}>x</button>
}
