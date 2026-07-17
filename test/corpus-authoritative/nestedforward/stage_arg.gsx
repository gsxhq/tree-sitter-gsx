package views

import "github.com/gsxhq/gsx"

func strAttr(a gsx.Attrs, key string) string {
	v, _ := a.Get(key)
	s, _ := v.(string)
	return s
}

component Icon(name string) {
	<span data-name={name}>i</span>
}

component Wrapper(base string, attrs gsx.Attrs) {
	<Icon name={ base |> default(strAttr(attrs, "fallback")) }/>
}

component Page() {
	<Wrapper base="" fallback="gear"/>
}
