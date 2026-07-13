package views

component Target(first string, last string) {
	<div { attrs... }>{first}{last}</div>
}

component Page() {
	<Target first={mark("plain-first", "A")} data-mid=f`@{mark("plain-mid", "M")}` last={mark("plain-last", "Z")}/>
}
