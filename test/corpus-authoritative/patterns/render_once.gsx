package views

var demoOnce = NewOnce()

component Once(handle *OnceHandle) {
	{ if handle.firstRender(ctx) { { children } } }
}

component Demo() {
	{{ ctx = withOnceScope(ctx) }}
	<Once handle={demoOnce}><span>x</span></Once>
	<Once handle={demoOnce}><span>x</span></Once>
}
