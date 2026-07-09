package views

component Card(title string, featured bool, count int) {
	<div class={ "card", "card-featured": featured }><h2>{title}</h2><span>{count}</span></div>
}

component Page(t string, n int) {
	<Card title={t} count={n}/>
}
