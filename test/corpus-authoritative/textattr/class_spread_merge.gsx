package views


import "github.com/gsxhq/gsx"
component Badge(variant string, attrs gsx.Attrs) {
	<span class=f`badge-@{variant}` { attrs... }>Hi</span>
}
