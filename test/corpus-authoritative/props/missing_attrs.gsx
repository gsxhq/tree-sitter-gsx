package views

component Button(variant string) {
	<button class={ variant }></button>
}

component Page() {
	<Button variant="primary" data-id="7"/>
}
