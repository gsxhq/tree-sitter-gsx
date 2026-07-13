package views

import "github.com/gsxhq/gsx"

component Pic(s string) {
	{{ b := gsx.Attrs{{Key: "srcset", Value: s}} }}
	<img { b... } alt="x"/>
}
