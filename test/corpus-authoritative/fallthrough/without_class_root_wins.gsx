package views

component Card() {
	<div class="card" { attrs.Without("class")... }>y</div>
}

component Page() {
	<Card class="hl" id="a"/>
}
