package views

type Form struct {
	Action string
}

component (f *Form) Render2(label string) {
	<form action={f.Action}>{label}</form>
}
