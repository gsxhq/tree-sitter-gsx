package views


import "github.com/gsxhq/gsx"
component Btn(a bool, b bool, attrs gsx.Attrs) {
	<button { attrs... } { if a { formaction="/x" } } { if b { formaction="/y" } }>x</button>
}

component Page() {
	<Btn a={true} b={false} formaction="javascript:alert(1)"/>
	<Btn a={false} b={true} formaction="javascript:alert(1)"/>
	<Btn a={false} b={false} formaction="javascript:alert(1)"/>
}
