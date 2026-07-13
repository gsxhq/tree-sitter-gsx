package views

import "github.com/gsxhq/gsx"

component Link(userHref string) {
	{{ b := gsx.Attrs{{Key: "id", Value: "drop"}, {Key: "href", Value: userHref}} }}
	<a { b.Without("id")... }>click</a>
}
