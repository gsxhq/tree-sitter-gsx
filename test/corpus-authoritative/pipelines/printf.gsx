package views

component C(count int, price float64, total int) {
	<p>{ count |> printf("%d comments") }</p>
	<span title={ price |> printf("$%.2f") }>{ price |> printf("$%.2f") }</span>
	<b>{ count |> printf("%d/%d", total) }</b>
}
