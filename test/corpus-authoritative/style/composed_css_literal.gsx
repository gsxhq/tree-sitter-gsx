package p
component Box(hidden bool, color string) {
	<div style={ "display:none": hidden, css`color:@{color};content:"\`"` }>x</div>
}
