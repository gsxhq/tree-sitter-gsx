package p

component BadScript(js []byte) {
	<script src=f`data:image/png;base64,@{js}`></script>
}
