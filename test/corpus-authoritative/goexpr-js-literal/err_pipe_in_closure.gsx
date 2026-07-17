package demo

import "github.com/gsxhq/gsx"

func take(j gsx.RawJS) gsx.Node { return gsx.Raw(string(j)) }

component Page(csv string) {
	<div>{ take(js`load(@{csv |> parse})`) }</div>
}
