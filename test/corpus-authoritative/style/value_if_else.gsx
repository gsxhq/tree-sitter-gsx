package views

component Box(active bool) {
	<div style={ "display: block", if active { "color: green" } else { "color: gray" } }>x</div>
}
