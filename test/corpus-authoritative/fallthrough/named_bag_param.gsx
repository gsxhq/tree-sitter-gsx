package views

import "github.com/gsxhq/gsx"

component Chip(extra gsx.Attrs) {
	<span a="b" { extra... }>x</span>
}

component Page() {
	<Chip extra={gsx.Attrs{{Key: "a", Value: "c"}}}/>
}
