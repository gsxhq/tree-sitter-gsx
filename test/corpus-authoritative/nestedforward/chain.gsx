package views


import "github.com/gsxhq/gsx"
component C(attrs gsx.Attrs) {
	<div class="c-root" data-scalar="c-default" { attrs... }>leaf</div>
}

component B(attrs gsx.Attrs) {
	<C class="b-add" { attrs... }/>
}

component A(attrs gsx.Attrs) {
	<B class="a-add" { attrs... }/>
}

component Page() {
	<A class="page-cls" data-scalar="page-value"/>
}
