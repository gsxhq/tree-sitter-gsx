package demo

import "github.com/gsxhq/gsx"

component Page(id string, c string) {
	<button @click=js`save('@{id}')`>a</button>
	<button @click={ js`save('@{id}')` }>b</button>
	{{ h := js`save('@{id}')` }}
	<button @click={h}>c</button>
	{{ clickAttrs := gsx.Attrs{{Key: "@click", Value: js`save('@{id}')`}} }}
	<button {clickAttrs...}>d</button>
	<div style=css`color:@{c}`>e</div>
	{{ sAttrs := gsx.Attrs{{Key: "style", Value: css`color:@{c}`}} }}
	<div {sAttrs...}>f</div>
}
