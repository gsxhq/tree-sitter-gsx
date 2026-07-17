package views

import "github.com/gsxhq/gsx"

component Link(attrs gsx.Attrs) {
	<a { attrs... }>go</a>
}

component Page() {
	<div>
		<Link href={"javascript:alert(1)"}/>
		<Link href={"/ok"}/>
	</div>
}
