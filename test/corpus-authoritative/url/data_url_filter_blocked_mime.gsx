package p

component Danger(bytes []byte) {
	<img src={ bytes |> dataURL("text/html") } alt="x" />
}
