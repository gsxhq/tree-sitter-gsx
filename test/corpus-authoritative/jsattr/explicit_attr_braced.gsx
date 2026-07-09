package p
component Button(id string) {
	<button @click={js`save(@{id})`}>Save</button>
}
