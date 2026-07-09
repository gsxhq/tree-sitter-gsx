package views

component Page(v string) {
	<div x-data="{ r: /@{ v }/ }">x</div>
}
