package demo

import "github.com/gsxhq/gsx"

component Widget(Handler gsx.RawJS, Rule gsx.RawCSS) {
	<button @click={Handler} data-style={Rule}>Go</button>
}

component Page(id string, w string) {
	<Widget Handler={ js`open(@{id})` } Rule={ css`width:@{w}px` }/>
}
