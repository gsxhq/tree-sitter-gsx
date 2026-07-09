package views

component Tag(ok bool, csv string) {
	<div class={ if ok { csv |> parse |> pick(0) } else { "z" } }>x</div>
}
