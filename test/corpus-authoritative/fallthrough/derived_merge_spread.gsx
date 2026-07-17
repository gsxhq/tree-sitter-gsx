package views

import "github.com/gsxhq/gsx"

component Row(extra gsx.Attrs, attrs gsx.Attrs) {
	<div data-a="root" { attrs.Merge(extra)... }>r</div>
}

component Page() {
	<Row extra={gsx.Attrs{{Key: "data-a", Value: "extra"}}} data-a="bag" id="i"/>
}
