package views

component Field(label string) { <input aria-label={label} { attrs... }/> }

component Page() {
	<Field
		label="Category"
		x-model=js`pdcaCategory`
		data-tip=`plain text`
		x-init=css`color:red`
	/>
}
