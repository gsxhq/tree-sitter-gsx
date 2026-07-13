package demo

import "github.com/gsxhq/gsx"

func mk(w int, color string) gsx.Attrs {
	return gsx.Attrs{{Key: "style", Value: css`width:@{w}px;color:@{color}`}}
}

component Page() {
	<div {mk(12, "teal")...} style="margin:0">x</div>
}
