package views

component Badge() {
	{{ f := func() string { return attrs.Class() } }}
	<span class={f()}>x</span>
}
