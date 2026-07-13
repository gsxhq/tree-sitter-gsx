package views

import "github.com/gsxhq/gsx"

component Pic(userSrc string) {
	{{ b := gsx.Attrs{{Key: "src", Value: userSrc}} }}
	<img { b... }/>
}
