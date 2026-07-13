package demo

import "github.com/gsxhq/gsx"

func mk(id string) gsx.RawJS {
	return js`open(@{id})`
}

component Page(id string) {
	<button @click={mk(id)}>Open</button>
}
