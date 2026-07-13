package views

component Card(title string) {
	<div>{title}</div>
}

component Page(u string, c bool) {
	<Card title="Hi" { if c { onclick=js"do(@{u})" } } />
}
