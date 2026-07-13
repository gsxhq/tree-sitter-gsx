package demo

import "github.com/gsxhq/gsx"

component Page(detail string) {
	{{
		containerAttrs := gsx.Attrs{
			{Key: "@suggest-datetime.window", Value: js`suggest(@{detail})`},
		}
	}}
	<div {containerAttrs...}>x</div>
}
