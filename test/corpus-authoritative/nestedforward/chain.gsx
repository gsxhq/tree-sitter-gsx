package views

component C() {
	<div class="c-root" data-scalar="c-default" { attrs... }>leaf</div>
}

component B() {
	<C class="b-add" { attrs... }/>
}

component A() {
	<B class="a-add" { attrs... }/>
}

component Page() {
	<A class="page-cls" data-scalar="page-value"/>
}
