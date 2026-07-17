package views

import "github.com/gsxhq/gsx"

component Target(first string, formatted string, ordered gsx.Attrs, last string, attrs gsx.Attrs) {
	<div { ordered... } { attrs... }>{first}{formatted}{last}</div>
}

component Page(fail bool) {
	<Target
		first={mark("first", "A")}
		formatted=f`value-@{markInt("hole", 7, fail)}`
		ordered={{ "data-pair": mark("pair", "P") }}
		data-bag={mark("bag", "B")}
		last={mark("last", "Z")}
	/>
}
