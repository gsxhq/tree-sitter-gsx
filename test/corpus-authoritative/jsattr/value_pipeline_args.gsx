package views

component Page(name string) {
	<div x-data="{ n: @{ name |> truncate(3) } }">x</div>
}
