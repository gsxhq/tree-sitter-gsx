package views


import "github.com/gsxhq/gsx"
component Badge(attrs gsx.Attrs) {
	{{ f := func() string { return attrs.Class() } }}
	<span class={f()}>x</span>
}
