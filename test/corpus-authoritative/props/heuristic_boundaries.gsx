package views

type Props struct {
	Title string
}

component Greeting(name string) {
	<p>Hi { name }</p>
}

component Card(title string, n int) {
	<div>{ title }: { n }</div>
}

component Panel(p Props) {
	<section>{ p.Title }</section>
}

component Page() {
	<>
		<Greeting name="Ann"/>
		<Card title="T" n={2}/>
		<Panel title="P"/>
	</>
}
