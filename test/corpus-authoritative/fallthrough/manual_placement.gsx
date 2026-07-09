package views

component Field(id string) {
	<div class="wrap"><input id={id} { attrs... }/></div>
}

component Page() {
	<Field id="email" data-test="x" placeholder="you@co"/>
}
