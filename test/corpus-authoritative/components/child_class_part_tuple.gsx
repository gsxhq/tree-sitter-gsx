package views

component Card(title string) { <div class="card">{title}</div> }

component Page(v int) {
	<Card title="Hi" class={ "base", cls(v) } />
}

func cls(v int) (string, error) { return "green", nil }
