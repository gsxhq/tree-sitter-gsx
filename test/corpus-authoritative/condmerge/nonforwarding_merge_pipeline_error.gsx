package views

component Box(on bool, gap string) {
	<div style="color:red" { if on { style={ gap |> decl } } }>x</div>
}
