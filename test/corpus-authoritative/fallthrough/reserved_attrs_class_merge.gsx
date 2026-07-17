package views

import "github.com/gsxhq/gsx"

component Card(attrs gsx.Attrs) {
	<section class="card" { attrs... }>x</section>
}

component Page() {
	<Card class="hl" id="c1"/>
}
