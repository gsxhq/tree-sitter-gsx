package views

component Widget() {
	<div
		x-data=js"{
			open: false,
			active: -1,
		}"
		style=css`
			color: red;
			margin: 0;
		`
	></div>
}
