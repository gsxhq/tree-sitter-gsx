package demo

component Page(who string) {
	<button onclick=js`f(@{ f`id-@{who}` })`>x</button>
}
