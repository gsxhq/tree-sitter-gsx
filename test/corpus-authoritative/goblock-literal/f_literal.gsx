package demo

component Page(name string) {
	{{ greeting := f`hello @{name}` }}
	<p>{greeting}</p>
}
