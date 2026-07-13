package views

import "github.com/gsxhq/gsx"

type imgProps struct {
	Attrs gsx.Attrs
}

type anchorProps struct {
	Attrs gsx.Attrs
}

component Img(p imgProps) {
	<img { p.Attrs... }/>
}

component Anchor(p anchorProps) {
	<a { p.Attrs... }>x</a>
}

component Page() {
	<div>
		<Img src={"data:image/png;base64,iVBORw0KGgo="}/>
		<Anchor href={"data:image/png;base64,iVBORw0KGgo="}/>
	</div>
}
