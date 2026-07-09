package views

type Props struct {
	Variant string
}

component Button(p Props) {
	<button class={ p.Variant }></button>
}

component Page() {
	<Button variant="primary">Save</Button>
}
