package views


import "github.com/gsxhq/gsx"
type Site struct{}

component (p Site) Item(attrs gsx.Attrs) {
	<li { attrs... }>x</li>
}

component (p Site) Row(attrs gsx.Attrs) {
	<p.Item { attrs... }/>
}

component (p Site) Home() {
	<p.Row data-x="1"/>
}
