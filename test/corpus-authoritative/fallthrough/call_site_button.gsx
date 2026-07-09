package views

component Button(variant string) {
	<button class="btn" data-variant={variant}>{children}</button>
}

component Page() {
	<Button variant="primary" class="w-full" data-test="x" hx-post="/go">Save</Button>
}
