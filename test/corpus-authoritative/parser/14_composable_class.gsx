package examples

component Link(active bool, class string) {
	<a class={
		"flex gap-2",
		"bg-active": active,
		class,
	}>link</a>
}
