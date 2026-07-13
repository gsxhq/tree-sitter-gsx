package views

type Site struct{}

component (p Site) Item() {
	<li { attrs... }>x</li>
}

component (p Site) Row() {
	<p.Item { attrs... }/>
}

component (p Site) Home() {
	<p.Row data-x="1"/>
}
