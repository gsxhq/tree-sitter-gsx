package views

import "github.com/gsxhq/gsx"

type chipProps struct { Attrs gsx.Attrs }

component renderChip(p chipProps) { <span { p.Attrs... }>chip</span> }

func Chip(attrs ...gsx.Attr) gsx.Node {
	return renderChip(chipProps{Attrs: gsx.Attrs(attrs)})
}

component Page(fail bool) {
	<Chip
		data-first={mark("first", "A")}
		attrs={{ "data-pair": markPair("pair", "P", fail) }}
		data-last={mark("last", "Z")}
	/>
}
