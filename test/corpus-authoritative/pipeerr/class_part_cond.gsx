package views

component Tag(v string, on bool) {
	<div class={ v |> upper: on }>x</div>
}
