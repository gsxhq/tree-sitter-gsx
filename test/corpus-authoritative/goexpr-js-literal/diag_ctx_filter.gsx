package demo

import "github.com/gsxhq/gsx"

func mk(v string) gsx.RawJS { return js`f(@{v |> up})` }

component Page(v string) {
	<button @click={mk(v)}>x</button>
}
