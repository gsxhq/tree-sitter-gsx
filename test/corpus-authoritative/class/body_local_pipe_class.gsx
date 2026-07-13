package views

component C() {
	{{ s := "hi" }}
	<b class={ s |> upper }>x</b>
}
