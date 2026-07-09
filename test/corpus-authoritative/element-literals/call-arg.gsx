package demo

component Foo() {
	<p>Foo body</p>
}

var wrapped = Wrap(<Foo/>)

component Uses() {
	<div>{ wrapped }</div>
}
