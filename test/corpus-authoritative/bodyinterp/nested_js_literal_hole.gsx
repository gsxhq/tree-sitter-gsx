package p

component Row(who string) {
	<p>{f`a @{ string(js`f(@{who})`) }`}</p>
}
