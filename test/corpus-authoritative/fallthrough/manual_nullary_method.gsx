package views


import "github.com/gsxhq/gsx"
type Pg struct{}

component (p Pg) Wrap(attrs gsx.Attrs) {
	<div class="outer"><span { attrs... }/></div>
}

component (p Pg) Page() {
	<p.Wrap data-test="x"/>
}
