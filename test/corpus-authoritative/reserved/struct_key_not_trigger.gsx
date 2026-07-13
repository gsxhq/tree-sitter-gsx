package views

type opt struct {
	attrs int
}

component Widget(label string) {
	{{ o := opt{attrs: 1} }}
	<div data-label={label} data-n={o.attrs}>x</div>
}
