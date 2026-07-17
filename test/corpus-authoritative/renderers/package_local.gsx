package views

import (
	"github.com/gsxhq/gsx"
	"corpustest/cases/renderers_package_local/pg"
)

func Timestamptz(v pg.Timestamptz) gsx.Node {
	return <time>{v.Label}</time>
}

func sample(label string) pg.Timestamptz { return pg.Timestamptz{Label: label} }

component Page(v pg.Timestamptz) {
	<div>{v}</div>
}
