package views

import "github.com/gsxhq/gsx"

component Link(userHref string) {
	{{ b := gsx.Attrs{{Key: "href", Value: userHref}} }}
	<a { b... }>click</a>
}
