package p
component Box(color string) {
	<div data-style=css`color:@{color |> upper}`>x</div>
}
