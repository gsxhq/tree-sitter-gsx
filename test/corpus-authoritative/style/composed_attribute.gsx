package views

component Badge(accent string, hide bool) {
	<span style={ "color: red", "color: " + accent, "display: none": hide }>hi</span>
}
