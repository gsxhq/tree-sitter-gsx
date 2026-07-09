package p

component Doc(name string) {
	<input
		type="checkbox"
		// own-line note
		id={name} // trailing note
		/* block note */
		{/* braced note */}
	/>
	<p>{/* block */}Visible{// line
	}text // literal</p>
}
