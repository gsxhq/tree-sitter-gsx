package views

import "github.com/gsxhq/gsx"

type linkProps struct {
	Attrs gsx.Attrs
}

component Link(p linkProps) {
	<a { p.Attrs... }>go</a>
}

component Page() {
	<div>
		<Link href={"javascript:alert(1)"}/>
		<Link href={"/ok"}/>
	</div>
}
