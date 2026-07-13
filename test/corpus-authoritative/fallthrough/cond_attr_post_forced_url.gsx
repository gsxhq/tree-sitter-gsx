package views

component Btn(active bool) {
	<button { attrs... } { if active { formaction="/forced" } }>x</button>
}

component Page() {
	<Btn active={true} formaction="javascript:alert(1)"/>
	<Btn active={false} formaction="javascript:alert(1)"/>
}
