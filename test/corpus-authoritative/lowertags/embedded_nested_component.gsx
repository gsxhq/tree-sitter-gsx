package views

import "github.com/gsxhq/gsx"

func wrap(n gsx.Node) gsx.Node { return n }

component Inner() {
	<i>in</i>
}

component card() {
	<em>c</em>
}

component Outer(children gsx.Node) {
	<b>{children}</b>
}

component Page() {
	<div>{ wrap(<Outer><Inner/><card/></Outer>) }</div>
}
