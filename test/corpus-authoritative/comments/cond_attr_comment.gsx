package views

component C(on bool) {
	<input
		{ if on {
			// enabled path
			checked
		} }
	/>
}
