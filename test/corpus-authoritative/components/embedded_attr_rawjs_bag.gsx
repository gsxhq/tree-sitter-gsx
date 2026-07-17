package demo


import "github.com/gsxhq/gsx"
component Field(label string, attrs gsx.Attrs) { <button aria-label={label} { attrs... }>x</button> }

component Page() {
	<Field
		label="Go"
		@click={ js`toggle()` }
		data-style={ css`color:red` }
	/>
}
