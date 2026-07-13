package views

import "github.com/gsxhq/gsx"

type props struct {
	Attrs gsx.Attrs
}

component Card(p props) {
	<section class="card" { p.Attrs... }>x</section>
}

component Page() {
	<Card class="hl" id="c1"/>
}
