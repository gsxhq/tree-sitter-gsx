package views


import "github.com/gsxhq/gsx"
component Card(attrs gsx.Attrs) {
	<div class="card" { attrs.Without("class")... }>y</div>
}

component Page() {
	<Card class="hl" id="a"/>
}
