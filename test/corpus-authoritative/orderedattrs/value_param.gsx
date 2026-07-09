package views

import "github.com/gsxhq/gsx"

component Card(bag gsx.Attrs) {
	<div { bag... }>x</div>
}

component Page(sig string) {
	<Card bag={{ "data-signals": sig }}/>
}
