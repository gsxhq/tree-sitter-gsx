package views

component Label(a string, b string) { <span>{a}{b}</span> }

component Page(csv string) {
	<Label a={ csv |> parse |> pick(0) } b={ shout() }/>
}

func shout() string { return "hi" }
