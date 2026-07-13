package demo

func mk(v string) string { return f`Hi @{v |> up}` }

component Page(v string) {
	<div>{ mk(v) }</div>
}
