package p

component Widget(v string) {
	<div class={f`btn-@{v}` |> upper}>x</div>
}
