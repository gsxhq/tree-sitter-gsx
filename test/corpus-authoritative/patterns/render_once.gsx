package views


import "github.com/gsxhq/gsx"
var demoOnce = NewOnce()

component Once(handle *OnceHandle, children gsx.Node) {
	{ if handle.firstRender(ctx) { { children } } }
}

component Demo() {
	{{ ctx = withOnceScope(ctx) }}
	<Once handle={demoOnce}><span>x</span></Once>
	<Once handle={demoOnce}><span>x</span></Once>
}
