package views

component Counter(label string) {
	{{ f := func(attrs []string) int { return len(attrs) } }}
	<div data-label={label} data-n={f(nil)}>x</div>
}
