package views

import "github.com/gsxhq/gsx"

component Theme(w int, accent string, raw gsx.RawCSS) {
	<style>.card{width:@{w}px;color:@{accent};border:@{raw}}</style>
}
