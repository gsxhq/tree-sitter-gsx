package views


import "github.com/gsxhq/gsx"
component Badge(attrs gsx.Attrs) {
	<span class=`badge @{lit}` { attrs... }>Hi</span>
}
