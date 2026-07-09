package views

component Card(p cardProps) {
	<div>{p.Header}{p.Icon}{p.Title}</div>
}

component Page(w widget) {
	<Card header="Hello" icon={w} title="World"/>
}
