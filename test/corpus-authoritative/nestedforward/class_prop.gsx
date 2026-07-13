package views

component Icon() {
	<span { attrs... }>i</span>
}

component Wrapper() {
	<Icon class={ attrs.Class() }/>
}

component Page() {
	<Wrapper class="w-5"/>
}
