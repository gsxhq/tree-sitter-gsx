package views


import "github.com/gsxhq/gsx"
component Button(variant string, children gsx.Node) {
	<button class="btn" data-variant={variant}>{children}</button>
}

component Page() {
	<Button variant="primary" class="w-full" data-test="x" hx-post="/go">Save</Button>
}
