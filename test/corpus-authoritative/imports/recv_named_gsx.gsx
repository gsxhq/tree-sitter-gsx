package demo

type widget struct {
	Label string
	Count int
}

component (gsx widget) Show() {
	<b>{ gsx.Label }</b>
}

component (strconv widget) Tally() {
	<i>{ strconv.Count }</i>
}
