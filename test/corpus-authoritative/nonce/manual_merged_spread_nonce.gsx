package views

import "github.com/gsxhq/gsx"

component Page(other gsx.Attrs) { <script { attrs.Merge(other)... }>init()</script> }
