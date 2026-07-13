package views

import "github.com/gsxhq/gsx"

func strAttr(a gsx.Attrs, key string) string {
	v, _ := a.Get(key)
	s, _ := v.(string)
	return s
}

type CardProps struct {
	Title string
	Attrs gsx.Attrs
}

component Card(p CardProps) {
	<div { p.Attrs... }>{p.Title}</div>
}

component Wrapper() {
	<Card title={ strAttr(attrs, "t") } data-x="1"/>
}

component Page() {
	<Wrapper t="hello"/>
}
