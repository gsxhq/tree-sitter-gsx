package demo

var n int

func next() int {
	n++
	return n
}

var handler = js`f(@{next()}, @{next()})`

component Page() {
	<button @click={handler}>x</button>
}
