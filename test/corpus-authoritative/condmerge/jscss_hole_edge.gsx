package views

component JSCssHoleCondClass(u string, active bool) {
	<button onclick=js"go(@{u})" { attrs... } { if active { class="on" } }>go</button>
}
