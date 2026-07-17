package views


import "github.com/gsxhq/gsx"
component Panel(attrs gsx.Attrs) {
	<div { attrs... }>p</div>
}

component Wrapper(attrs gsx.Attrs) {
	<Panel { attrs.Without("id")... }/>
}

component Page() {
	<Wrapper id="ignore-me" data-keep="yes"/>
}
