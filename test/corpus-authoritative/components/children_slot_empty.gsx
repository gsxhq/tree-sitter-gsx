package views

component Card(title string) {
	<section><h2>{title}</h2>{children}</section>
}

component Page() {
	<Card title="Hi"/>
}
