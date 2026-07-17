package demo

import "github.com/gsxhq/gsx"

component Page(path string) {
	{{
		a := gsx.Attrs{
			{Key: "@change", Value: js`@{path} = 1;`},
		}
	}}
	<input {a...}/>
}
