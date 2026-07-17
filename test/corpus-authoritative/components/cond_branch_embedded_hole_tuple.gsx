package views


import "github.com/gsxhq/gsx"
func hi() (string, error) { return "there", nil }

component Field(label string, attrs gsx.Attrs) { <input aria-label={label} { attrs... }/> }

component Page(edit bool) {
	<Field label="c" { if edit { title=f"Hi @{hi()}" } } />
}

component FailPage(edit bool) {
	<Field label="c" { if edit { title=f"Hi @{fail()}" } } />
}
