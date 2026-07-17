package demo

component Page(who string) {
	<p title=f`hi @{ f`name: @{who}` }!`>x</p>
}
