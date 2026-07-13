package views

component Plain(title string) {
	<h1>{title}</h1>
}

component Page() {
	<Plain title="t" data-x="1"/>
}
