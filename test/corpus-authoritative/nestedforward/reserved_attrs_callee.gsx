package views

import "github.com/gsxhq/gsx"

func strAttr(a gsx.Attrs, key string) string {
	v, _ := a.Get(key)
	s, _ := v.(string)
	return s
}

component Card(title string, attrs gsx.Attrs) {
	<div { attrs... }>{title}</div>
}

component Wrapper(attrs gsx.Attrs) {
	<Card title={ strAttr(attrs, "t") } data-x="1"/>
}

component Page() {
	<Wrapper t="hello"/>
}
