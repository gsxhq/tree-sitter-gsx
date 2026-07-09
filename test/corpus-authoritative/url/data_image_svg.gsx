package p

component Icon(svgB64 string) {
	<img src=f`data:image/svg+xml;base64,@{svgB64}` alt="i" />
}
