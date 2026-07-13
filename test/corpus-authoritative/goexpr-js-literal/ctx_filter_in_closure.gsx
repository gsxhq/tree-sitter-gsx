package demo

import "github.com/gsxhq/gsx"

func take(j gsx.RawJS) gsx.Node { return gsx.Raw(string(j)) }

component Page(v string) {
	<div>{ take(js`f(@{v |> up})`) }</div>
}
