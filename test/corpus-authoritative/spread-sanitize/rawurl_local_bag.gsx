package views

import "github.com/gsxhq/gsx"

component Link() {
	{{ b := gsx.Attrs{{Key: "href", Value: gsx.RawURL("app://ok")}} }}
	<a { b... }>click</a>
}
