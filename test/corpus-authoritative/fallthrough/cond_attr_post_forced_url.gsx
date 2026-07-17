package views


import "github.com/gsxhq/gsx"
component Btn(active bool, attrs gsx.Attrs) {
	<button { attrs... } { if active { formaction="/forced" } }>x</button>
}

component Page() {
	<Btn active={true} formaction="javascript:alert(1)"/>
	<Btn active={false} formaction="javascript:alert(1)"/>
}
