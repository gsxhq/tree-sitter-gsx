package views


import "github.com/gsxhq/gsx"
component Panel(attrs gsx.Attrs) {
	{{ attrs = attrs.Without("id") }}
	<div { attrs... }>x</div>
}
