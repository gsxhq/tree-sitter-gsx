package views

component Card(title string) { <div class="card">{title}</div> }

component Page(v int) {
	<Card title="Hi" class={ "base", cls(v) } />
}

func cls(v int) (int, string) { return 1, "x" }
