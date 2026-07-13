package views

var trace string

func mark(label, value string) string {
	trace += label
	return value
}

component Ordered(on bool) {
	{{ trace = "" }}
	<div style={ mark("a", "color:red") } data-n={42} { if on { style={ mark("b", "margin:0") } } } style={ mark("c", "padding:1px") }>{ trace }</div>
}
