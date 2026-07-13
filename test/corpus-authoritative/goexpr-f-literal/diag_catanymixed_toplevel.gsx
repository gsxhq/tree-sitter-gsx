package demo

func mk[T string | int](v T) string { return f`Hi @{v}` }

component Page(v string) {
	<div>{ mk(v) }</div>
}
