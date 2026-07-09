package views

component Card(title string) {
	<div>{title}</div>
}

component Page() {
	<Card mystery-attrs={{ "data-x": "1" }}/>
}
