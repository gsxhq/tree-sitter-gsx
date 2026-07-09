package examples

component Status(ok bool, warn bool) {
	<header>
		{ if ok {
			<h2>OK</h2>
		} else if warn {
			<h2>Warn</h2>
		} else {
			<h2>Fail</h2>
		} }
	</header>
}
