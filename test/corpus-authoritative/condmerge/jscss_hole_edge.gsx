package views


import "github.com/gsxhq/gsx"
component JSCssHoleCondClass(u string, active bool, attrs gsx.Attrs) {
	<button onclick=js"go(@{u})" { attrs... } { if active { class="on" } }>go</button>
}
