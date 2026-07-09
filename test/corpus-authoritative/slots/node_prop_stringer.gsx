package views

import "github.com/gsxhq/gsx"

component Label(text gsx.Node) {
	<span>{text}</span>
}

component Page(t tag) {
	<Label text={t}/>
}
