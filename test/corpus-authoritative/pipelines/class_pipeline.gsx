package views

component C(theme string, active bool) {
	<div class={ theme |> upper, "on" : active }>x</div>
}
