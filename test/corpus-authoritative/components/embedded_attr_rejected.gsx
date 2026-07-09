package views

component Card(title string) {
	<div>{title}</div>
}

component Page(id string) {
	<Card title="Hi" x-model=js`items[@{id}]`/>
}
