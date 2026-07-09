package views

component Tag(csv string) {
	<div class={ csv |> parse |> pick(0) }>x</div>
}
