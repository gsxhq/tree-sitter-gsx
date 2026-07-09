package p

component Button(x string) {
	<button @click=js"const t = `hi @{x}`; send(t)">Save</button>
}
