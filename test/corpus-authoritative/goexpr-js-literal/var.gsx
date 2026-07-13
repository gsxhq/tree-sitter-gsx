package demo

var id = "abc"

var handler = js`save(@{id})`

component Page() {
	<button @click={handler}>Save</button>
}
