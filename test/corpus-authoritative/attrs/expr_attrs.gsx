package views

component Link(url string, label string, n int, checked bool) {
	<a href={url} data-label={label} data-n={n} aria-hidden={checked}>{label}</a>
}
