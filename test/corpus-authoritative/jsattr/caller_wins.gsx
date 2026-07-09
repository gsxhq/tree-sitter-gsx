package views

component Panel(tab string) {
	<div x-data="{ tab: @{ tab } }" { attrs... }>slot</div>
}
