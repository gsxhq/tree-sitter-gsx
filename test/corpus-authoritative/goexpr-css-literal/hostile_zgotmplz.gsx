package demo

import "github.com/gsxhq/gsx"

func mk(color string) gsx.RawCSS {
	return css`color:@{color}`
}

component Box(color string) {
	<div style={ mk(color) }>x</div>
}
