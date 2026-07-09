package views

component Field(label string) { <input aria-label={label} { attrs... }/> }

component Page(edit bool) {
	<Field label="Category" { if edit { x-model=js`pdcaCategory` } } />
}
