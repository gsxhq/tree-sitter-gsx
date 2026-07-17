package views


import "github.com/gsxhq/gsx"
component Field(label string, attrs gsx.Attrs) { <input aria-label={label} { attrs... }/> }

component Page(edit bool, who string) {
	<Field label="Category" { if edit { title=f"Hi @{who}" } } />
}
