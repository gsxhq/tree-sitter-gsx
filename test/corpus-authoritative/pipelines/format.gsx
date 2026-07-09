package views

component C(count int, price float64, total int) {
	<p>{ count |> format("%d comments") }</p>
	<span title={ price |> format("$%.2f") }>{ price |> format("$%.2f") }</span>
	<b>{ count |> format("%d/%d", total) }</b>
}
