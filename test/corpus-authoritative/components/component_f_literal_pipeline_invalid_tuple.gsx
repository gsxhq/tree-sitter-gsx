package views

component Header(text string) { <h1>{text}</h1> }

func bad() (int, string) { return 0, "not an error" }

component Page() {
	<Header text=f`item-@{bad()}`/>
}
