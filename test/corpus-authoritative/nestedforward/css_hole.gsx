package views

import "github.com/gsxhq/gsx"

func strAttr(a gsx.Attrs, key string) string {
	v, _ := a.Get(key)
	s, _ := v.(string)
	return s
}

component Widget(attrs gsx.Attrs) {
	<div style={ css`color:@{ strAttr(attrs, "c") }` }>x</div>
}

component Page() {
	<Widget c="red"/>
}
