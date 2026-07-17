package demo

import "github.com/gsxhq/gsx"

component Wide(Handler gsx.RawJS) {
	<button onclick={Handler}>b</button>
}

component Page(id string) {
	<button onclick=js`save('@{id |> parse}')`>a</button>
	<Wide Handler={ js`save('@{id |> parse}')` }/>
}
