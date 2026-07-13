package demo

import "github.com/gsxhq/gsx"

component Page(color string) {
	{{ s := gsx.Attrs{{Key: "style", Value: css`color:@{color}`}} }}
	<div {s...} style="margin:0">x</div>
}
