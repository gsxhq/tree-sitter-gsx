package views

import "github.com/gsxhq/gsx"

component Widget(x string) {
	{{
		a := gsx.Attrs{
			{Key: "x-data", Value: js`{
				open: false,
				active: -1,
			}`},
			{Key: "style", Value: css`
				color: red;
				margin: 0;
			`},
			{Key: "@change", Value: js`
				const v = 1;
				@{gsx.RawJS(x)} = v;
			`},
		}
	}}
	<div {a...}>y</div>
}
