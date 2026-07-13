package views

component Panel() {
	{{ attrs = attrs.Without("id") }}
	<div { attrs... }>x</div>
}
