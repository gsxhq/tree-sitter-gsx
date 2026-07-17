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
		<Img p={imgProps{Attrs: gsx.Attrs{{Key: "src", Value: "data:image/png;base64,iVBORw0KGgo="}}}}/>
		<Anchor p={anchorProps{Attrs: gsx.Attrs{{Key: "href", Value: "data:image/png;base64,iVBORw0KGgo="}}}}/>
	</div>
}
