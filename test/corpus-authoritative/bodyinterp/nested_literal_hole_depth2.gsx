package p

component Row(who string) {
	<p>{f`a @{ f`b @{who}` } c`}</p>
}
