package demo

component Page(who string) {
	<p>{ wrap(f`a @{ string(js`f(@{who})`) }`) }</p>
}
