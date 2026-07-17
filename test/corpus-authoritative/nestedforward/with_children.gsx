package views


import "github.com/gsxhq/gsx"
component Panel(children gsx.Node, attrs gsx.Attrs) {
	<section { attrs... }>{children}</section>
}

component Wrapper(attrs gsx.Attrs) {
	<Panel { attrs... }>text child</Panel>
}

component Page() {
	<Wrapper data-x="1"/>
}
