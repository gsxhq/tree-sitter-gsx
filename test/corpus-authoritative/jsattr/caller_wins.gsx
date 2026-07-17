package views


import "github.com/gsxhq/gsx"
component Panel(tab string, attrs gsx.Attrs) {
	<div x-data="{ tab: @{ tab } }" { attrs... }>slot</div>
}
