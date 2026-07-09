package views

component C(theme string, on bool) {
	<div class={ "base", if on { theme |> upper } else { "off" } }>x</div>
}
