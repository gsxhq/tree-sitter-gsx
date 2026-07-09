package views

import "github.com/gsxhq/gsx"

component Box(bag gsx.Attrs) {
	<div { bag... }>x</div>
}

component Page() {
	<Box bag={gsx.Attrs{{Key: "data-signals", Value: "{c:0}"}, {Key: "data-text", Value: "$c"}, {Key: "data-a", Value: "z"}}}/>
}
