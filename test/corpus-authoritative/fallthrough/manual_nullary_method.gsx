package views

type Pg struct{}

component (p Pg) Wrap() {
	<div class="outer"><span { attrs... }/></div>
}

component (p Pg) Page() {
	<p.Wrap data-test="x"/>
}
