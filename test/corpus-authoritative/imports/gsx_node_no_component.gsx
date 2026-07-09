package demo

import "github.com/gsxhq/gsx"

func wrap(n gsx.Node) gsx.Node { return n }

var _ = wrap
