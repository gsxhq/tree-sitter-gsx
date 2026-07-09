package views

component Card(title string, featured bool, count int) {
	<div><h2>{title}</h2><span>{count}</span></div>
}

component Page(n int) {
	<Card title="Hello" count={n}/>
}
