package p

component Avatar(b64 string) {
	<img src=f`data:image/png;base64,@{b64}` alt="a" />
}
