package examples

component Chip(name string) {
	<div>
		{{ initials := f(name) }}
		<span>{initials}</span>
	</div>
}
