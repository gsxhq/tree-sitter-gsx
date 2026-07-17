package demo

import "github.com/gsxhq/gsx"

component Page(xModelPath string) {
	{{
		syncAttrs := gsx.Attrs{
			{Key: "@change", Value: js`const foundId = lookup($event);
@{gsx.RawJS(xModelPath)} = foundId;`},
		}
	}}
	<input {syncAttrs...}/>
}
