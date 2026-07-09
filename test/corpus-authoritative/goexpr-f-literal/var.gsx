package demo

var name = "world"

var greeting = f`hello @{name}`

component Uses() {
	<p>{ greeting }</p>
}
