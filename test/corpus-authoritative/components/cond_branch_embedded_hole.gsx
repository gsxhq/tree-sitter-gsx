package views

component Field(label string) { <input aria-label={label} { attrs... }/> }

component Page(edit bool, who string) {
	<Field label="Category" { if edit { title=f"Hi @{who}" } } />
}
