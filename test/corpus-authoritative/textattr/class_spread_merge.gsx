package views

component Badge(variant string) {
	<span class=f`badge-@{variant}` { attrs... }>Hi</span>
}
