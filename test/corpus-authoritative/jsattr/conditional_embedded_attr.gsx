package p
component Button(active bool, id string) {
	<button { if active { @click=js`save(@{id})` } }>Save</button>
}
