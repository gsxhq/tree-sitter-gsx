package views

component Widget() {
	<div class={ if attrs.Has("on") { "on" } }>x</div>
}

component Page() {
	<Widget on="1"/>
}
