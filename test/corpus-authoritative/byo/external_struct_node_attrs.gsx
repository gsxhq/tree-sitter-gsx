package views

component Card(p CardProps) {
	<section class="card">
		<h2>{p.Title}</h2>
		{p.Children}
	</section>
}

component Page() {
	<Card Title="Hello">
		<p>body</p>
	</Card>
}
