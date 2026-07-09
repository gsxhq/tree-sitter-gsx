package p

component Bad(png []byte) {
	<a href=f`data:image/png;base64,@{png}`>x</a>
}
