package views

import "github.com/gsxhq/gsx"

type myAttr gsx.Attr

var Bad = func(a []myAttr) gsx.Node { return nil }

component Page() {
	<Bad class="x"/>
}
