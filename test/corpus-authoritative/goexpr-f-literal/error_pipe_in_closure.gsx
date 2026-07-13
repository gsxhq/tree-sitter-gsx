package demo

component Page(v string) {
	<div>{ take(f`Hi @{v |> must}`) }</div>
}
