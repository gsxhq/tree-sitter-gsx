package views

component C() {
	{{ outer := true }}
	{{ inner := true }}
	{{ armv := "deep" }}
	<button { if outer { class={ "btn", if inner { armv } } } }>x</button>
}
