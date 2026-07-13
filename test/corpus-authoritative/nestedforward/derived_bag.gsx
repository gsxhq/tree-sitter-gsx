package views

component Panel() {
	<div { attrs... }>p</div>
}

component Wrapper() {
	<Panel { attrs.Without("id")... }/>
}

component Page() {
	<Wrapper id="ignore-me" data-keep="yes"/>
}
