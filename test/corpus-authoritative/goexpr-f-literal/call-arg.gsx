package demo

component Item(n int) {
	<div>{ wrap(f`id-@{n}`) }</div>
}
