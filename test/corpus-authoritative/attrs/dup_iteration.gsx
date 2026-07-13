package views

import "github.com/gsxhq/gsx"

component EchoLen() {
	{{ v, _ := attrs.Get("a"); s, _ := v.(string) }}
	<div data-n={len(attrs)}>{s}</div>
}

component Page(extra gsx.Attrs) {
	<EchoLen a="1" { extra... }/>
}
