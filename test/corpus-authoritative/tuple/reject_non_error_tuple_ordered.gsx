package views

import "github.com/gsxhq/gsx"

func twoVals() (int, string) { return 1, "x" }

component Card(bag gsx.Attrs) {
	<div { bag... }/>
}

component Page() {
	<Card bag={{ "x": twoVals() }}/>
}
