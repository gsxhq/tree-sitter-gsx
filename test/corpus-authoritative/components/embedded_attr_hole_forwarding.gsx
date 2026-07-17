package views

import "github.com/gsxhq/gsx"

component Link(attrs gsx.Attrs) {
	<a {attrs...}>go</a>
}

component Page(v string) {
	<Link
		onclick=js`call(@{v})`
		style=css`content:@{v}`
		href="javascript:alert(1)"
	/>
}
