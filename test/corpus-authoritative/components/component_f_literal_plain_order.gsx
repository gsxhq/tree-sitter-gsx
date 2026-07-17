package views


import "github.com/gsxhq/gsx"
component Target(first string, last string, attrs gsx.Attrs) {
	<div { attrs... }>{first}{last}</div>
}

component Page() {
	<Target first={mark("plain-first", "A")} data-mid=f`@{mark("plain-mid", "M")}` last={mark("plain-last", "Z")}/>
}
