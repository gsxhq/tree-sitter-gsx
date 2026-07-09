package views

import "github.com/gsxhq/gsx"

type MyMap map[string]any

component Card(bag gsx.Attrs) {
	<div { bag... }>x</div>
}

component Page() {
	<Card bag={MyMap{"b": "2", "a": "1"}}/>
}
