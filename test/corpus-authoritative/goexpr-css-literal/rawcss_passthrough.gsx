package demo

import "github.com/gsxhq/gsx"

var accent gsx.RawCSS = "color:red"

var Combined = css`base;@{accent}`

component Page() {
	<div style={ Combined }>x</div>
}
