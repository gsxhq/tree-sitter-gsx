package demo

import "github.com/gsxhq/gsx"

component Wide(Handler gsx.RawJS) {
	<button onclick={Handler}>x</button>
}

component Page(id string) {
	<Wide Handler={ js`go(@{id |> parse})` }/>
}
