package demo

component Field(label string) { <button aria-label={label} { attrs... }>x</button> }

component Page() {
	<Field
		label="Go"
		@click={ js`toggle()` }
		data-style={ css`color:red` }
	/>
}
