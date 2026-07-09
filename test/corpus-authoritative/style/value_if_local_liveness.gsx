package views

component C() {
	{{ wide := true }}
	<div style={ "display: block", if wide { "width: 100%" } }>x</div>
}
