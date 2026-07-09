package p
component Button(name string) {
	<button @click=js`save(\`hi @{name}\`)`>Save</button>
}
