package views

component card() {
	<div class="card">{children}</div>
}

component Page() {
	<card>hi</card>
	<span>bye</span>
}
