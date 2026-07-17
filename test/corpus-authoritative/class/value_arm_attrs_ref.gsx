package views


import "github.com/gsxhq/gsx"
component Widget(attrs gsx.Attrs) {
	<div class={ if attrs.Has("on") { "on" } }>x</div>
}

component Page() {
	<Widget on="1"/>
}
