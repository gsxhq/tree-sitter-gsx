package views

import "github.com/gsxhq/gsx"

component Link(linkAttrs gsx.Attrs) {
	<a { linkAttrs... }>go</a>
}

component Page() {
	<Link linkAttrs={{ "HREF": "javascript:alert(1)" }}/>
}
