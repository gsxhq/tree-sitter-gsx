package demo

import "github.com/gsxhq/gsx"

component Page(prop string, name string) {
	{{
		a := gsx.Attrs{
			{Key: "@click", Value: js`obj.@{gsx.RawJS(prop)} = 1; let @{gsx.RawJS(name)} = 2;`},
		}
	}}
	<button {a...}>x</button>
}
