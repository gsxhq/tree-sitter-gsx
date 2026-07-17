package views

import "github.com/gsxhq/gsx"

component Card(p CardProps, children gsx.Node) {
	<section class="card">
		<h2>{p.Title}</h2>
		{children}
	</section>
}

component Page() {
	<Card p={CardProps{Title: "Hello"}}>
		<p>body</p>
	</Card>
}
