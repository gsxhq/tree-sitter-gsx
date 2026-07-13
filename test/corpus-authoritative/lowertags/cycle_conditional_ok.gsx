package views

component div(deep bool) {
	if deep {
		<span>{children}</span>
	}
	<div>{children}</div>
}

component span() {
	<span><div>{children}</div></span>
}

component Page() {
	<p>hi</p>
}
