package views

import "github.com/gsxhq/gsx"

component Pic(on bool, s string) {
	{{ b := gsx.Attrs{{Key: "srcset", Value: s}} }}
	<img alt="x" { if on { { b... } } }/>
}
