package views

func hi() (string, error) { return "there", nil }

component Field(label string) { <input aria-label={label} { attrs... }/> }

component Page(edit bool) {
	<Field label="c" { if edit { title=f"Hi @{hi()}" } } />
}

component FailPage(edit bool) {
	<Field label="c" { if edit { title=f"Hi @{fail()}" } } />
}
