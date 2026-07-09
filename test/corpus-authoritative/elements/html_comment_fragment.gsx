package views

component C(show bool) {
	<>
		<!-- oob -- swap -->
		{ if show { <p>yes</p> } else { <p>no</p> } }
	</>
}
