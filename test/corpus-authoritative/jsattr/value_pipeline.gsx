package views

component Page(name string) {
	<div x-data="{ n: @{ name |> upper } }">x</div>
}
