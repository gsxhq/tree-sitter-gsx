package demo

import "github.com/gsxhq/gsx"

func mkAttrs(id string) gsx.Attrs {
	return gsx.Attrs{
		{Key: "@click", Value: js`select(@{id})`},
		{Key: "x-data", Value: js`dialog(@{id})`},
	}
}

component Panel(id string) {
	<button {mkAttrs(id)...}>Pick</button>
}
