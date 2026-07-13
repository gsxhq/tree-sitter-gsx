package demo

component Page(v string) {
	{{ x := f`Hi @{v |> must}` }}
	<div>{ x }</div>
}
