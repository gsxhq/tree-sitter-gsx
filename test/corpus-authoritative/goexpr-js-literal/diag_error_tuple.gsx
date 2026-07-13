package demo

func risky() (string, error) { return "x", nil }

var h = js`f(@{risky()})`

component Page() {
	<button @click={h}>x</button>
}
