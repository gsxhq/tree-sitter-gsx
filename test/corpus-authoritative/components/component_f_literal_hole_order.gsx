package views

component Label(text string) {
	<span>{text}</span>
}

component Page(fail bool) {
	<Label text=f`@{value("first")} @{fallible(fail)} @{value("third")}`/>
}
