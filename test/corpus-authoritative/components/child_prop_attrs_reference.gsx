package views

component Child() {
	<div { attrs... }>child</div>
}

component Wrapper() {
	<Child class={attrs.Class()}/>
}
