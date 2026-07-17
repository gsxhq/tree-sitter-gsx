package demo

import "github.com/gsxhq/gsx"

component Page(path string) {
	<input @change=js`@{gsx.RawJS(path)} = foundId;`/>
}
