package views


import "github.com/gsxhq/gsx"
component Field(label string, attrs gsx.Attrs) { <input aria-label={label} { attrs... }/> }

component Page(edit bool) {
	<Field label="Category" { if edit { x-model=js`pdcaCategory` } } />
}
