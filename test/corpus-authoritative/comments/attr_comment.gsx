package views

component C(name string) {
	<input
		type="checkbox"
		// own-line note
		id={name} // trailing note
		/* block note */
		{/* braced note */}
		value="x"
	/>
}
