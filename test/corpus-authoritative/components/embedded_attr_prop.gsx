package views


import "github.com/gsxhq/gsx"
component Field(label string, attrs gsx.Attrs) { <input aria-label={label} { attrs... }/> }

component Page() {
	<Field
		label="Category"
		x-model=js`pdcaCategory`
		data-tip=`plain text`
		x-init=css`color:red`
	/>
}
