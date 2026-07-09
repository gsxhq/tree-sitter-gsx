package views

component Page(v string) {
	<div x-data="{ s: `@{ v }` }">x</div>
}
