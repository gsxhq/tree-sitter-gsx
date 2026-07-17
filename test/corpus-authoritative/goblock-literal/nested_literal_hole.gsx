package demo

component Page() {
	{{ h := f`a @{ f`b` }` }}
	<p>{h}</p>
}
