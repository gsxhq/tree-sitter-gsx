package views

import "github.com/gsxhq/gsx"

func strAttr(a gsx.Attrs, key string) string {
	v, _ := a.Get(key)
	s, _ := v.(string)
	return s
}

component Panel(attrs gsx.Attrs) {
	<div { attrs... }>p</div>
}

component Wrapper(attrs gsx.Attrs) {
	<Panel attrs={{ "data-n": strAttr(attrs, "n") }}/>
}

component Page() {
	<Wrapper n="7"/>
}
