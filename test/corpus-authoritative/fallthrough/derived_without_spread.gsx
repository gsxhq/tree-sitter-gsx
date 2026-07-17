package views


import "github.com/gsxhq/gsx"
component Panel(title string, attrs gsx.Attrs) {
	<section class="panel" data-role="box" { attrs.Without("data-skip")... }>{title}</section>
}

component Page() {
	<Panel title="Hi" class="hl" data-role="caller" data-skip="x" id="p1"/>
}
