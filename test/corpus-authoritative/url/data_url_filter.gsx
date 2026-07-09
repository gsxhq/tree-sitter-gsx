package p

component Avatar(png []byte) {
	<img src={ png |> dataURL("image/png") } alt="a" />
}
