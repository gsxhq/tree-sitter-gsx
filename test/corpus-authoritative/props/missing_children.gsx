package views

component Button(variant string) {
	<button class={ variant }></button>
}

component Page() {
	<Button variant="primary">Save</Button>
}
