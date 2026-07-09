package demo

var cls = "text-lg"
var label = "Home"

var help = <span class={ cls }>{ label }</span>

component Uses() {
	<div>{ help }</div>
}
