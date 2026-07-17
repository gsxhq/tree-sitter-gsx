package views


import "github.com/gsxhq/gsx"
component Link(attrs gsx.Attrs) {
	<a { attrs... }>go</a>
}

component Wrapper(attrs gsx.Attrs) {
	<Link { attrs... }/>
}

component Page() {
	<Wrapper href="javascript:alert(1)"/>
}
