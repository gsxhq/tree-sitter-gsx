package demo

import "github.com/gsxhq/gsx"

func take(j gsx.RawJS) gsx.Node { return gsx.Raw(string(j)) }

component Page(a string, b string) {
	<p>{ take(js`f(@{a}, @{b |> parse})`) }</p>
}
