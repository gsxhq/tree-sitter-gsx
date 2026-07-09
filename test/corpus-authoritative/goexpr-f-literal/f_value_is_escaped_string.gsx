package views

func markup(x string) string { return f`<b>@{x}</b>` }

component Host(x string) {
	<div>{ markup(x) }</div>
}
