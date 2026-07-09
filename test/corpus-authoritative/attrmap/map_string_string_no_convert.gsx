package views

import "github.com/gsxhq/gsx"

component Card(bag gsx.Attrs) {
	<div { bag... }>x</div>
}

component Page() {
	<Card bag={map[string]string{"id": "x"}}/>
}
