package views

component Card(p cardData) {
	<h2>{ p.Title }</h2>
}

component Page() {
	<Card title="Hi"/>
}
