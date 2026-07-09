package views

component Card(title string) { <div class="card">{title}</div> }

component Page(v int, flag bool) {
	<Card title="Hi" class={ "base", if flag { cls(v) } else { "gray" } } />
}

func cls(v int) (string, error) { return "green", nil }
