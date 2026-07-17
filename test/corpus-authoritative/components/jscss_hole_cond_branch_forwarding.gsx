package views

import "github.com/gsxhq/gsx"

component Sink(attrs gsx.Attrs) {
	<div {attrs...}>x</div>
}

component BranchPage(on bool) {
	<Sink { if on {
		data-before={mark("before")}
		onclick=js`call(@{pair("js")})`
		style=css`color:@{mark("css")}`
		data-after={mark("after")}
	} else {
		data-else={mark("else")}
	} }/>
}

component ErrorPage() {
	<Sink { if true {
		data-before={mark("before")}
		onclick=js`call(@{fail("error")})`
		style=css`color:@{mark("late-css")}`
		data-after={mark("after")}
	} else {
		data-else={mark("unreachable-else")}
	} }/>
}
