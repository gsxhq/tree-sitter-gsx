package views

component div() {
	<div><span>{children}</span></div>
}

component span() {
	<span><div>{children}</div></span>
}

component Page() {
	<p>hi</p>
}
